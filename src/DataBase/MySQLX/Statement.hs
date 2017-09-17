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

module DataBase.MySQLX.Statement 
  (
   -- * SQL Execution
   executeSql
  ,executeSqlMetaData
  ,executeRawSql
  ,executeRawSqlMetaData
  ,updateSql
  ,updateRawSql
   -- * ResultSet operations
  ,ColumnValuable(..)
  ,getColInt64
  ,getColString
  ,cutNull
   -- ** ResultSet MetaData Operation
  ,getColMetaType
  ,getColMetaName
  ) where

-- general, standard library
import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM)
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

-- generated library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Any                                as PA
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType           as PCMDFT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Frame                              as PFr
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Row                                as PR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.SessionStateChanged                as PSSC

-- protocolbuffers
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers                as PB

-- my library
import DataBase.MySQLX.Exception
import DataBase.MySQLX.NodeSession 
import DataBase.MySQLX.Model

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
  runReaderT (_sendStmtExecuteSql sql param) nodeSess
  ret <- runReaderT readMessagesR nodeSess
  return $ join $ map ((map PR.field) . getRow . snd) $ filter (\(t, b) -> t == s_resultset_row) ret 
  
-- | Raw Select Interface with meta data
executeRawSqlMetaData :: (MonadIO m, MonadThrow m) 
                      => String            -- ^ SQL string
                      -> NodeSession       -- ^ Node sessin
                      -> m (Seq.Seq PCMD.ColumnMetaData, [Seq.Seq BL.ByteString]) -- ^ Result Set tuple (metadata, result)
executeRawSqlMetaData sql nodeSess = executeSqlMetaData sql [] nodeSess 

-- | Select binding Interface with meta data
executeSqlMetaData :: (MonadIO m, MonadThrow m) 
                     => String             -- ^ SQL string
                     -> [PA.Any]           -- ^ parameters
                     -> NodeSession        -- ^ Node session 
                     -> m (Seq.Seq PCMD.ColumnMetaData, [Seq.Seq BL.ByteString]) -- ^ Result Set tuple (metadata, result)
executeSqlMetaData sql param nodeSess = do
  runReaderT (_sendStmtExecuteSql sql param) nodeSess
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
getColMetaType :: Seq.Seq PCMD.ColumnMetaData -> Int -> PCMDFT.FieldType 
getColMetaType meta idx = getColumnType $ Seq.index meta idx 

-- | get a name of column.
getColMetaName :: Seq.Seq PCMD.ColumnMetaData -> Int -> T.Text
getColMetaName meta idx = getColumnName $ Seq.index meta idx 

-- | get a content type of column.
getColMetaContentType :: Seq.Seq PCMD.ColumnMetaData -> Int -> ColumnContentType 
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
updateSql :: (MonadIO m, MonadThrow m) 
          => String       -- ^ SQL string
          -> [PA.Any]     -- ^ parameters
          -> NodeSession  -- ^ Node session
          -> m W.Word64   -- ^ result (# of affected rows)
updateSql sql param nodeSess = do
  runReaderT (_sendStmtExecuteSql sql param) nodeSess
  ret@(x:xs) <- runReaderT readMessagesR nodeSess   -- [(Int, B.ByteString)]
  if fst x == s_error then do
    msg <- getError $ snd x
    throwM $ XProtocolError msg
  else do 
    frm <- (getFrame . snd ) $ head $ filter (\(t, b) -> t == s_notice) ret  -- Frame
    ssc <- getPayloadSessionStateChanged frm
    getRowsAffected ssc

-- -----------------------------------------------------------------------------
-- internal use 
-- -----------------------------------------------------------------------------
_sendStmtExecuteSql :: (MonadIO m) => String -> [PA.Any] -> ReaderT NodeSession m () 
_sendStmtExecuteSql sql args  = writeMessageR $ mkStmtExecuteSql sql args

