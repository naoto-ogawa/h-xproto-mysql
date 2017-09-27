{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables, TemplateHaskell,  TypeInType, TypeFamilies, KindSignatures, DataKinds, TypeOperators, GADTs, TypeSynonymInstances, FlexibleInstances #-}

{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}

module Example.Example09 where

import Language.Haskell.TH
import Language.Haskell.TH.Syntax

import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM, bracket, catch)
import Control.Monad
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class
import qualified Data.Aeson           as JSON 
import qualified Data.ByteString      as B
import qualified Data.Binary          as Bin
import qualified Data.Binary.Get      as BinG
import qualified Data.Binary.Strict.BitGet as SBinG
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Int             as I
import Data.Kind           
import qualified Data.Sequence        as Seq
import qualified Data.Text            as T
import qualified Data.Text.Encoding   as TE
import qualified Data.Word            as W

-- protocolbuffers
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers.Extensions     as PBE
import qualified Text.ProtocolBuffers                as PB

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DataModel                          as PDM
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Delete                             as PD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert                             as PI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find                               as PF
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Frame                              as PFr
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Warning                            as PW

-- my library
import DataBase.MySQLX.CRUD           as CRUD
import DataBase.MySQLX.Exception
import DataBase.MySQLX.JSON
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement
import DataBase.MySQLX.TH
import DataBase.MySQLX.Util

import GHC.Generics

-- ======================================================================= --
-- 
-- ======================================================================= --

{-
+NO_ERROR

case_a : 1  -> 2 -> 3  -> 4 -> 5   ([1,2,3,4,5],            )
case_b : 1  -> 2 -> 3  -> 4 -> 5'  ([1,2,3,4]  , [5]        )
case_c : 1  -> 2 -> 3' -> 4 -> 5   ([1,2]      , [3,4,5]    )
case_d : 1' -> 2 -> 3  -> 4 -> 5   ([]         , [1,2,3,4,5])

success
success + warning
error

-}

nodeSession :: IO NodeSession
nodeSession = openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

{-
create table test_users( id int not null, name  varchar(20), email varchar(20), point int);
-}

-- valid
sql1 = "insert into test_users values (1, 'mike'  , 'mike@example.com'  ,  45);"
sql2 = "insert into test_users values (2, 'nancy' , 'nancy@example.com' , 115);"
sql3 = "insert into test_users values (3, 'steve' , 'steve@example.com' , 298);"
sql4 = "insert into test_users values (4, 'james' , 'steve@example.com' , 444);"
sql5 = "insert into test_users values (5, 'jhon'  , 'steve@example.com' , 555);"
-- invalid
sql1' = "insert into test_users' values (1, 'mike'  , 'mike@example.com'  ,  45);"
sql2' = "insert into test_users' values (2, 'nancy' , 'nancy@example.com' , 115);"
sql3' = "insert into test_users' values (3, 'steve' , 'steve@example.com' , 298);"
sql4' = "insert into test_users' values (4, 'james' , 'steve@example.com' , 444);"
sql5' = "insert into test_users' values (5, 'jhon'  , 'steve@example.com' , 555);"

exec = sendStmtExecuteSql 

case_a :: ReaderT NodeSession IO ()
case_a = exec sql1 [] >> exec sql2 [] >> exec sql3 [] >> exec sql4 [] >> exec sql5 [] 
 
case_b :: ReaderT NodeSession IO ()
case_b = exec sql1 [] >> exec sql2 [] >> exec sql3 [] >> exec sql4 [] >> exec sql5' [] 
 
case_c :: ReaderT NodeSession IO ()
case_c = exec sql1 [] >> exec sql2 [] >> exec sql3' [] >> exec sql4 [] >> exec sql5 [] 
 
case_d :: ReaderT NodeSession IO ()
case_d = exec sql1' [] >> exec sql2 [] >> exec sql3 [] >> exec sql4 [] >> exec sql5 [] 
 
example09_normalbase :: ReaderT NodeSession IO () -> IO ()
example09_normalbase test_case  = do
  putStrLn "start example09_01"
  nodeSess <- nodeSession 
  
  runReaderT test_case nodeSess

  ret <- replicateM 5 $ runReaderT readMessagesR nodeSess
  print ret

  putStrLn "end   example09_01"
  return ()

makeNoExpect sqls = do  
  sendExpectNoError
  sqls 
  sendExpectClose

example09 :: ReaderT NodeSession IO () -> IO ([Message], [Message]) 
example09 = example09_base False

example09_NoError :: ReaderT NodeSession IO () -> IO ([Message], [Message]) 
example09_NoError = example09_base True 

example09_base :: Bool -> ReaderT NodeSession IO () -> IO ([Message], [Message]) 
example09_base noerror test_case = do
  putStrLn "start"
  nodeSess <- nodeSession 
 
  if noerror 
  then do 
    runReaderT (makeNoExpect test_case) nodeSess
  else do
    runReaderT test_case nodeSess

  ret <- runReaderT (repeatreadMessagesR noerror 5 ([],[])) nodeSess
  print $ length $ fst ret
  print $ length $ snd ret
  print ret

  putStrLn "end"
  return ret 

--
-- Test Case
--

example09_normal_a :: IO ()
example09_normal_a = example09_normalbase case_a

example09_normal_b :: IO ()
example09_normal_b = example09_normalbase case_b

example09_normal_c :: IO ()
example09_normal_c = example09_normalbase case_c

example09_normal_d :: IO ()
example09_normal_d = example09_normalbase case_d

-- splite success and error

example09_tuple_case_a :: IO ([Message], [Message]) 
example09_tuple_case_a = example09 case_a

example09_tuple_case_b :: IO ([Message], [Message]) 
example09_tuple_case_b = example09 case_b

example09_tuple_case_c :: IO ([Message], [Message]) 
example09_tuple_case_c = example09 case_c

example09_tuple_case_d :: IO ([Message], [Message]) 
example09_tuple_case_d = example09 case_d

example09_NoError_case_a :: IO ([Message], [Message]) 
example09_NoError_case_a = example09_NoError case_a

example09_NoError_case_b :: IO ([Message], [Message]) 
example09_NoError_case_b = example09_NoError case_b

example09_NoError_case_c :: IO ([Message], [Message]) 
example09_NoError_case_c = example09_NoError case_c

example09_NoError_case_d :: IO ([Message], [Message]) 
example09_NoError_case_d = example09_NoError case_d

