-- {-# #-}

module DataBase.MySQLX.Document
  ( 
   createCollection 
  ,dropCollection
--  ,insertDocument
  ) where

-- general, standard library
import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM)
import Control.Monad
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class

import qualified Data.Word                      as W
import Data.UUID
import Data.UUID.V4
import qualified Data.Sequence                  as Seq

-- generated library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Any                                as PA
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Collection                         as PCll
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DataModel                          as PDM
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Expr                               as PEx
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert.TypedRow                    as PITR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert                             as PI

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB
import qualified Text.ProtocolBuffers.Basic          as PBB
import qualified Text.ProtocolBuffers.Header         as PBH
import qualified Text.ProtocolBuffers.TextMessage    as PBT
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers.Reflections    as PBR

-- my library
import DataBase.MySQLX.Exception
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession 
import DataBase.MySQLX.Util

sendStmtExecuteX :: (MonadIO m, MonadThrow m) => String -> [PA.Any] -> ReaderT NodeSession m ()
sendStmtExecuteX stmt args = do 
  debug $ "stmtExecute = " ++ (show s)
  writeMessageR s
  where s = mkStmtExecuteX' stmt args

--sendInsertX:: (MonadIO m, MonadThrow m) => String -> String -> String -> ReaderT NodeSession m ()
--sendInsertX schema table json = do
--  debug insert
--  writeMessageR insert 
--  where insert = mkInsertX schema table json 

createCollection :: (MonadIO m, MonadThrow m) => String -> String -> NodeSession -> m ()
createCollection schema table nodeSess = _doCollection "create_collection" schema table nodeSess

dropCollection :: (MonadIO m, MonadThrow m) => String -> String -> NodeSession -> m ()
dropCollection schema table nodeSess = _doCollection "drop_collection" schema table nodeSess

--insertDocument :: (MonadIO m, MonadThrow m) => String -> String -> String -> NodeSession -> m W.Word64
--insertDocument schema table json nodeSess = do
--  uuid <- liftIO $ nextRandom
--  runReaderT (reader uuid) nodeSess
--  (t, byte):xs <- runReaderT readMessagesT nodeSess
--  if t == s_error then do
--    msg <- getError byte 
--    throwM $ XProtocolError msg
--  else do 
--    frm <- getFrame byte
--    ssc <- getPayloadSessionStateChanged frm
--    getRowsAffected ssc
--  where
--    reader uuid = sendInsertX schema table (insertUUID json $ removeUnderscore $ toString uuid)
--    removeUnderscore x = foldr (\x a -> if x == '-' then a else x : a) [] x

insertUUIDExpr :: PEx.Expr -> IO PEx.Expr
insertUUIDExpr ex = do
   newJson <- insertUUIDIO $ exprVal' ex
   return $ expr newJson

-- insertUUIDIO :: String -> IO String

--
-- helpers
--
_doCollection :: (MonadIO m, MonadThrow m) => String -> String -> String -> NodeSession -> m ()
_doCollection operation schema table nodeSess = do
  runReaderT reader nodeSess
  (t, byte):xs <- runReaderT readMessagesT nodeSess
  if t == s_error then do
    msg <- getError byte 
    throwM $ XProtocolError msg
  else do 
    ok <- getStmtExecuteOk byte
    debug ok
    return ()
  where reader = sendStmtExecuteX
                 operation
                 [
                   anyObject $ setObject 
                     [
                       setObjectField "schema" $ XM.any schema
                      ,setObjectField "name"   $ XM.any table 
                     ]
                 ]

