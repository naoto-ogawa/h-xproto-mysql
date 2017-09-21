{-# LANGUAGE DeriveGeneric, ScopedTypeVariables, TemplateHaskell,  TypeInType, TypeFamilies, KindSignatures, DataKinds, TypeOperators, GADTs, TypeSynonymInstances, FlexibleInstances #-}

module Example.Example07 where

import Language.Haskell.TH
import Language.Haskell.TH.Syntax

import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM, bracket, catch)
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
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find                               as PF

-- my library
import DataBase.MySQLX.Exception
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement
import DataBase.MySQLX.TH
import DataBase.MySQLX.Util
import DataBase.MySQLX.CRUD           as CRUD

import GHC.Generics

-- ======================================================================= --
-- Enum 
-- ======================================================================= --

{-

mysql-sql> create table data_type_enum (my_enum enum('aaa', 'bbb', 'ccc'));
Query OK, 0 rows affected (0.06 sec)
mysql-sql> insert into data_type_enum values ('ddd');
Query OK, 1 row affected, 1 warning (0.01 sec)
Warning (code 1265): Data truncated for column 'my_enum' at row 1
mysql-sql> select * from data_type_enum;
+---------+
| my_enum |
+---------+
|         |
+---------+
1 row in set (0.00 sec)
mysql-sql> insert into data_type_enum values ('aaa');
Query OK, 1 row affected (0.00 sec)
mysql-sql> select * from data_type_enum;
+---------+
| my_enum |
+---------+
|         |
| aaa     |
+---------+
2 rows in set (0.00 sec)
mysql-sql> delete from data_type_enum;
Query OK, 2 rows affected (0.01 sec)
mysql-sql> insert into data_type_enum values ('bbb');
Query OK, 1 row affected (0.01 sec)
mysql-sql> select * from data_type_enum;
+---------+
| my_enum |
+---------+
| bbb     |
+---------+
1 row in set (0.00 sec)
mysql-sql>

-}

example07_01 :: IO ()
example07_01 = do
  putStrLn "start example07_01"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  (meta, ret@(x:xs)) <- executeRawSqlMetaData "select * from data_type_enum limit 1" nodeSess

  print meta
  print ret 
  print $ (BL.length (Seq.index x 0) )

  return ()


