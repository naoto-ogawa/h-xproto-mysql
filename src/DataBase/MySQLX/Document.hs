{- |
module      : DataBase.MySQLX.Document
description : Basic Operations for Collections
copyright   : (c) naoto ogawa, 2017
license     : MIT 
maintainer  :  
stability   : experimental
portability : 
-}
module DataBase.MySQLX.Document
  (
  -- * Basic Operations for Collections
    createCollection 
  , dropCollection
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

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- | Create a collection.
createCollection :: (MonadIO m, MonadThrow m) 
  => String      -- ^ schema
  -> String      -- ^ table
  -> NodeSession -- ^ node session
  -> m ()
createCollection = _doCollection "create_collection" 

-- | Drop a collection.
dropCollection :: (MonadIO m, MonadThrow m) 
  => String      -- ^ schema
  -> String      -- ^ table
  -> NodeSession -- ^ node session
  -> m ()
dropCollection = _doCollection "drop_collection" 

--
-- helpers
--
_doCollection :: (MonadIO m, MonadThrow m) => String -> String -> String -> NodeSession -> m ()
_doCollection operation schema table nodeSess = do
  runReaderT reader nodeSess
  (t, byte):xs <- runReaderT readMessagesR nodeSess
  if t == s_error then do
    msg <- getError byte 
    throwM $ XProtocolError msg
  else do 
    ok <- getStmtExecuteOk byte
    debug ok
    return ()
  where reader = _sendStmtExecuteX
                 operation
                 [
                   XM.any $ setObject 
                     [
                       setObjectField "schema" $ XM.any schema
                      ,setObjectField "name"   $ XM.any table 
                     ]
                 ]

_sendStmtExecuteX :: (MonadIO m, MonadThrow m) => String -> [PA.Any] -> ReaderT NodeSession m ()
_sendStmtExecuteX stmt args = do 
  debug $ "stmtExecute = " ++ (show s)
  writeMessageR s
  where s = mkStmtExecuteX' stmt args

