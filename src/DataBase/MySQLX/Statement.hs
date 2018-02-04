{- |
module      : DataBase.MySQLX.Statement
description : SQL Operations
copyright   : (c) naoto ogawa, 2017
license     : MIT 
maintainer  :  
stability   : experimental
portability : 
-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE RecordWildCards      #-}

module DataBase.MySQLX.Statement 
  (
   -- * SQL Execution
   executeSql
  ,executeSqlMetaData
  ,executeRawSql
  ,executeRawSqlMetaData
  ,updateSql
  ,updateSql'
  ,updateRawSql
   -- * ResultSet operations
  ,ColumnValuable(..)
  ,getColInt64
  ,getColInt32
  ,getColString
  ,cutNull
   -- ** ResultSet MetaData Operation
  ,getColMetaType
  ,getColMetaName
   -- ** Convenience functions
  ,execSimpleTx
  ,execSimpleTx'
   -- ** Generic Sql operations
  ,sendStmtExecuteSql 
  ,responseUpdateSql' 
  ) where

-- general, standard library
import Control.Exception      (SomeException)
import Control.Exception.Safe 
import Control.Monad
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Int             as I
import qualified Data.Sequence        as Seq
import qualified Data.Text            as T
import qualified Data.Text.Encoding   as TE
import qualified Data.Maybe           as M
import qualified Data.Word            as W

-- import Network.Socket.Types

-- generated library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Any                                as PA
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType           as PCMDFT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Frame                              as PFr
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Row                                as PR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.SessionStateChanged                as PSSC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Warning                            as PW

-- protocolbuffers
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers                as PB

-- my library
import DataBase.MySQLX.Exception
import DataBase.MySQLX.NodeSession 
import DataBase.MySQLX.Model
import DataBase.MySQLX.ResultSet
import DataBase.MySQLX.Util

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- SELECT Interface
-- -----------------------------------------------------------------------------

-- | Raw Select Interface (without meta data)
executeRawSql :: (MonadIO m, MonadThrow m) 
              => String                    -- ^ SQL string
              -> NodeSession               -- ^ Node session
              -> m [Seq.Seq BL.ByteString] -- ^ Result Set
executeRawSql sql nodeSess = executeSql sql [] nodeSess 

-- |  Select binding Interface (without meta data)
executeSql :: (MonadIO m, MonadThrow m) 
           => String                       -- ^ SQL string
           -> [PA.Any]                     -- ^ parameters
           -> NodeSession                  -- ^ Node session
           -> m [Seq.Seq BL.ByteString]    -- ^ Result Set
executeSql sql param nodeSess = do
  runReaderT (sendStmtExecuteSql sql param) nodeSess
  ret <- runReaderT readMessagesR nodeSess
  return $ join $ map ((map PR.field) . getRow . snd) $ filter (\(t, b) -> t == s_resultset_row) ret 
  
-- | Raw Select Interface with meta data
executeRawSqlMetaData :: (MonadIO m, MonadThrow m) 
                      => String            -- ^ SQL string
                      -> NodeSession       -- ^ Node sessin
                      -> m (ResultSetMetaData, [Seq.Seq BL.ByteString]) -- ^ Result Set tuple (metadata, result)
executeRawSqlMetaData sql nodeSess = executeSqlMetaData sql [] nodeSess 

-- | Select binding Interface with meta data
executeSqlMetaData :: (MonadIO m, MonadThrow m) 
                     => String             -- ^ SQL string
                     -> [PA.Any]           -- ^ parameters
                     -> NodeSession        -- ^ Node session 
                     -> m (ResultSetMetaData, [Seq.Seq BL.ByteString]) -- ^ Result Set tuple (metadata, result)
executeSqlMetaData sql param nodeSess = do
  runReaderT (sendStmtExecuteSql sql param) nodeSess
  ret <- runReaderT readMessagesR nodeSess
  return $ tupleRfmap ((map PR.field) . join)  -- m (_, [m Row]) -> m (_, [Row]) -> (_, [Seq ByteString])
         $ tupleLfmap ( Seq.fromList  . join)  -- m ([m ColumnMetaData], _) -> m ([ColumnMetaData], _) -> m (Seq ColumnMetaData, _)
         $ foldr f ([], []) ret                -- collect ColumnMetaData and Row, throw away others
  where f = \(t, b) (meta, rows) -> 
              if t == s_resultset_column_meta_data then
                 (getColumnMetaData b : meta , rows           )
              else if t == s_resultset_row then
                 (meta                       , getRow b : rows)
              else
                 (meta                       , rows           ) 
        tupleLfmap f (a,b) = (f a,   b)
        tupleRfmap         = fmap 

-- -----------------------------------------------------------------------------
-- Retrive ResultSet
-- -----------------------------------------------------------------------------

-- | retrive String from a Row. (NULL is ignored.)
getColString :: Seq.Seq BL.ByteString -> Int -> String
getColString = (T.unpack .) . (getColText) -- two parameters point free style (U.unpack . getColText a b)

-- | from ByteString to String.
getColString' :: BL.ByteString -> String
getColString' = T.unpack . getColText'

-- | retrive Text from a Row. (NULL is ignored.)
getColText :: Seq.Seq BL.ByteString -> Int -> T.Text 
getColText seq idx = TE.decodeUtf8 $ BL.toStrict $ getColByteString seq idx 

-- | from ByteString to Text.
getColText' :: BL.ByteString -> T.Text 
getColText' = TE.decodeUtf8 . BL.toStrict

-- | retrive Int64 from a Row.
getColInt64 :: Seq.Seq BL.ByteString  -- ^ a Row 
            -> Int                    -- ^ column index 
            -> I.Int64                -- ^ Int64
getColInt64 seq idx = PBW.zzDecode64 $ PBW.getFromBS PBW.getVarInt $ Seq.index seq idx

-- | from ByteString to Int64.
getColInt64' :: BL.ByteString -> I.Int64
getColInt64' = PBW.zzDecode64 . PBW.getFromBS PBW.getVarInt

-- | retrive Int32 from a Row.
getColInt32 :: Seq.Seq BL.ByteString  -- ^ a Row 
            -> Int                    -- ^ column index 
            -> I.Int32                -- ^ Int32
getColInt32 seq idx = PBW.zzDecode32 $ PBW.getFromBS PBW.getVarInt $ Seq.index seq idx

-- | from ByteString to Int32.
getColInt32' :: BL.ByteString -> I.Int32
getColInt32' = PBW.zzDecode32 . PBW.getFromBS PBW.getVarInt

-- | remove null value from a ByteString.
getColByteString :: Seq.Seq BL.ByteString -> Int -> BL.ByteString
getColByteString seq idx = BL.take len byte
  where byte = Seq.index seq idx
        len  = BL.length byte - 1 -- last bytes is null

-- | remove null value
cutNull :: BL.ByteString -> BL.ByteString
cutNull byte = BL.take len byte
  where len  = BL.length byte - 1 -- last bytes is null

-- | retrieve a column value from ByteString in ResultSet
class ColumnValuable a where toColVal :: BL.ByteString -> a
instance ColumnValuable Int     where toColVal = fromIntegral . getColInt64'
instance ColumnValuable I.Int64 where toColVal = getColInt64'
instance ColumnValuable String  where toColVal = getColString' . cutNull

--
-- Retrive ResultSet MetaData
--
-- | get a type of column.
getColMetaType :: ResultSetMetaData -> Int -> PCMDFT.FieldType 
getColMetaType meta idx = getColumnType $ Seq.index meta idx 

-- | get a name of column.
getColMetaName :: ResultSetMetaData -> Int -> T.Text
getColMetaName meta idx = getColumnName $ Seq.index meta idx 

-- | get a content type of column.
getColMetaContentType :: ResultSetMetaData -> Int -> ColumnContentType 
getColMetaContentType meta idx = getContentType $ Seq.index meta idx 

-- -----------------------------------------------------------------------------
-- INSERT / Update / Detelte / etc. Interface
-- -----------------------------------------------------------------------------

-- | Modify Operations (Insert / Update / Delete / Others)
updateRawSql :: (MonadIO m, MonadThrow m) 
             => String      -- ^ SQL string 
             -> NodeSession -- ^ Node session
             -> m W.Word64  -- ^ result (# of affected rows)
updateRawSql sql nodeSess = updateSql sql [] nodeSess 

-- TODO to implement generated_insert_id 

-- | Modify Operations (Insert / Update / Delete / Others)
-- Even if a server message is a OK, XProtocolWarn are thrown in case of a Warning.
--
updateSql :: (MonadIO m, MonadThrow m) 
          => String       -- ^ SQL string
          -> [PA.Any]     -- ^ parameters
          -> NodeSession  -- ^ Node session
          -> m W.Word64   -- ^ result (# of affected rows)
updateSql sql param nodeSess = do
  (warn, rows) <- updateSql' sql param nodeSess
  case warn of
    Nothing -> return rows
    Just w  -> throwM $ XProtocolWarn w

-- | Modify Operations (Insert / Update / Delete / Others)
--
-- Even if we have OK message, we may have a warning.
--
-- example
-- @
-- [
--    Frame { type' = 1
--          , scope = Just LOCAL
--          , payload = Just "\b\SOH\DLE\140\n\SUBMIncorrect date value: '2023-09-17T19:23:54.000' for column 'my_date' at row 1"}
--   ,Frame { type' = 3
--          , scope = Just LOCAL
--          , payload = Just "\b\EOT\DC2\EOT\b\STX\CAN\SOH"
--          }
--  ] 
-- @
-- 
-- the above Frames are encoded as follows :
-- @
-- Warning {level = Just NOTE, code = 1292, msg = "Incorrect date value: '2023-09-17T19:23:54.000' for column 'my_date' at row 1"}
-- SessionStateChanged {param = ROWS_AFFECTED, value = Just (Scalar {type' = V_UINT, v_signed_int = Nothing, v_unsigned_int = Just 1, v_octets = Nothing, v_double = Nothing, v_float = Nothing, v_bool = Nothing, v_string = Nothing})}
-- @
-- 
updateSql' :: (MonadIO m, MonadThrow m) 
          => String                -- ^ SQL string
          -> [PA.Any]              -- ^ parameters
          -> NodeSession           -- ^ Node session
          -> m (Maybe PW.Warning, W.Word64)  -- ^ A pare of a message and result (# of affected rows)
updateSql' sql param nodeSess = do
  runReaderT (sendStmtExecuteSql sql param) nodeSess
  responseUpdateSql' nodeSess

-- | Retreive both a warning and a updated count from One Server response.
responseUpdateSql' :: (MonadThrow m, MonadIO m) 
                   => NodeSession                    -- ^ Node Session 
                   -> m (Maybe PW.Warning, W.Word64) -- ^ A pare of a message and result (# of affected rows)
responseUpdateSql' nodeSess = do
  ret@(x:xs) <- runReaderT readMessagesR nodeSess
  if fst x == s_error then do
    msg <- getError $ snd x
    -- debug msg
    return (Nothing, 0)
    -- throwM $ XProtocolError msg
  else do 
    frms <- sequence $ map (\(t,b) -> getFrame b) $ filter (\(t, b) -> t == s_notice) ret -- [Frame]
    -- debug frms
    let warn = safeHead $ filterWarnings frame_warning frms >>= getPayloadWarning
    ssc  <- getPayloadSessionStateChanged $ head $ filterWarnings frame_session_state_changed frms
    rows <- getRowsAffected ssc
    return (warn, rows)
  where 
    filterWarnings = \t frames -> filter (\PFr.Frame{..} -> type' == t) frames

-- repeatResponseUpdateSql :: (MonadThrow m, MonadIO m) 
--                    => NodeSession                    -- ^ Node Session 
--                    -> Int                            -- ^ the number of messages in a Pipline
--                    -> m (Maybe PW.Warning, W.Word64) -- ^ A pare of a message and result (# of affected rows)


-- -----------------------------------------------------------------------------
-- Convenience functions
-- -----------------------------------------------------------------------------
-- | Execute database operations with transaction.
execSimpleTx :: (MonadIO m, MonadThrow m, MonadCatch m, MonadMask m)
             => String                 -- ^ Database 
             -> String                 -- ^ User
             -> String                 -- ^ Password
             -> (NodeSession -> m a)   -- ^ some database operatoins 
             -> m () 
execSimpleTx = execSimpleTx' "127.0.0.1" 33060 

-- | Execute database operations with transaction.
execSimpleTx' :: (MonadIO m, MonadThrow m, MonadCatch m, MonadMask m)
             => String                 -- ^ IP
             -> Int                    -- ^ Port
             -> String                 -- ^ Database 
             -> String                 -- ^ User
             -> String                 -- ^ Password
             -> (NodeSession -> m a)   -- ^ some database operatoins 
             -> m () 
execSimpleTx' host port database user pw func = 
  bracket
    (do -- first
       nodeSess <- openNodeSession $ defaultNodeSesssionInfo {
                                       host     = host
                                     , port     = toEnum port
                                     , database = database
                                     , user     = user
                                     , password = pw
                                     }
       begenTrxNodeSession nodeSess
       return nodeSess
    )
    (\nodeSess -> do -- last
       closeNodeSession  nodeSess
       return nodeSess
    )
    (\nodeSess -> do -- in between
         func nodeSess
         commitNodeSession nodeSess
         return ()
       `catches` 
         [
           handleError (\ex -> do
              liftIO $ print $ "catching XProtocolError : " ++ (show ex) 
              rollbackNodeSession nodeSess
              return ()
           )
         , handleWarn  (\ex -> do
              liftIO $ print $ "catching XProtocolWarn : " ++ (show ex) 
              rollbackNodeSession nodeSess
              return ()
           )
         , handleException $ (\ex -> do
             liftIO $ print $ "catching XProtocolException : " ++ (show ex) 
             rollbackNodeSession nodeSess
             return ()
           )
         -- The last resort.
         , Handler $ (\(ex :: SomeException) -> do
             liftIO $ print $ "SomeException : " ++ (show ex)
             rollbackNodeSession nodeSess
             return ()
           )
         ]
    )

-- -----------------------------------------------------------------------------
--  
-- -----------------------------------------------------------------------------
-- | Generic Sql execution
sendStmtExecuteSql :: (MonadIO m) 
                   => String      -- ^ SQL statment 
                   -> [PA.Any]    -- ^ bind parameters
                   -> ReaderT NodeSession m () 
sendStmtExecuteSql sql args  = writeMessageR $ mkStmtExecuteSql sql args

