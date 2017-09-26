{-# LANGUAGE DeriveGeneric, ScopedTypeVariables, TemplateHaskell,  TypeInType, TypeFamilies, KindSignatures, DataKinds, TypeOperators, GADTs, TypeSynonymInstances, FlexibleInstances #-}

module Example.Example06 where

import Language.Haskell.TH
import Language.Haskell.TH.Syntax

import           Control.Exception (SomeException)
import           Control.Exception.Safe
import qualified Data.Aeson           as JSON 
import qualified Data.ByteString      as B
import qualified Data.Binary          as Bin
import qualified Data.Binary.Get      as BinG
import qualified Data.Binary.Strict.BitGet as SBinG
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Int             as I
import           Data.Kind           
import qualified Data.Sequence        as Seq
import           Data.Time
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
import DataBase.MySQLX.DateTime
import DataBase.MySQLX.Exception
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement
import DataBase.MySQLX.TH
import DataBase.MySQLX.Util
import DataBase.MySQLX.CRUD           as CRUD

import GHC.Generics

-- ======================================================================= --
-- YEAR
-- ======================================================================= --

{-
create table data_type_year (my_year year);

15:34:03.792092 IP localhost.33060 > localhost.51926: Flags [P.], seq 260:394, ack 145, win 12754, options [nop,nop,TS val 312635905 ecr 312635905], length 134
	0x0000:  4500 00ba f6d4 4000 4006 0000 7f00 0001  E.....@.@.......
	0x0010:  7f00 0001 8124 cad6 7ccd 8d10 0b3c 3226  .....$..|....<2&
	0x0020:  8018 31d2 feae 0000 0101 080a 12a2 7201  ..1...........r.
	0x0030:  12a2 7201 5300 0000 0c08 0212 076d 795f  ..r.S........my_ 10   53 = 83  0c = RESULTSET_COLUMN_META_DATA
	0x0040:  7965 6172 1a07 6d79 5f79 6561 7222 0e64  year..my_year".d 16
	0x0050:  6174 615f 7479 7065 5f79 6561 722a 0e64  ata_type_year*.d 16
	0x0060:  6174 615f 7479 7065 5f79 6561 7232 0f78  ata_type_year2.x 16
	0x0070:  5f70 726f 746f 636f 6c5f 7465 7374 3a03  _protocol_test:. 16
	0x0080:  6465 6640 0048 0050 0458 0005 0000 000d  def@.H.P.X...... 9    58 = 85  
	0x0090:  0a02 e10f 0500 0000 0d0a 02e0 0f01 0000  ................      0a02e10f  0a02e00f 
                                                                                \\n  \\STX  \\225  \\SI
                                                                                0a   02      e1      0f 

	0x00a0:  000e 0f00 0000 0b08 0310 021a 0808 0412  ................      e = 14 result_fetch_don  0f = 15, b = 11 -> Notice 
	0x00b0:  0408 0218 0001 0000 0011                 ..........            11 = 17 OK
-}
example06_01 :: IO ()
example06_01 = do
  putStrLn "start example6_01"
  nodeSess <- nodeSession 

  (meta, ret@(x:xs)) <- executeRawSqlMetaData "select * from data_type_year limit 1" nodeSess

  print meta
  print ret 
  -- print $ (BL.length (Seq.index x 0) )
  -- print $ (BinG.runGet BinG.getWord16le (Seq.index x 0))
  let b = Seq.index x 0
  print $ getColDay' b

  return ()




-- ======================================================================= --
-- DATE
-- ======================================================================= --

{-

sql-sql> create table data_type_date (my_date date);
Query OK, 0 rows affected (0.07 sec)

mysql-sql> insert into data_type_date values (date('2017-09-17'));
Query OK, 1 row affected (0.02 sec)

mysql-sql> select * from data_type_date;
+--------------------+
| my_date            |
+--------------------+
| 2017-10-17 0:00:00 |
+--------------------+
-}

example06_02 :: IO ()
example06_02 = do
  putStrLn "start example6_02"
  nodeSess <- nodeSession 

  (meta, ret@(x:xs)) <- executeRawSqlMetaData "select * from data_type_date limit 1" nodeSess

  print meta
  print ret 
  let b = Seq.index x 0
  print $ getColDay' b
  -- print $ (BL.length b )
  -- print $ (BinG.runGet example06_02_1 b)

  return ()

-- example06_02_1 :: BinG.Get String
-- example06_02_1 = do
--   y <- BinG.getWord16le 
--   m <- BinG.getWord8
--   d <- BinG.getWord8 
--   return $ (show (y-2048)) ++ "-" ++ (show m) ++ "-" ++ (show d)

example06_02_Insert :: IO ()
example06_02_Insert = execSimpleTx "x_protocol_test" "root" "root" example06_02_Insert'

example06_02_Insert' :: NodeSession -> IO ()
example06_02_Insert' nodeSess = do

  ret <- updateSql "insert into data_type_date values (?)"  [XM.any y] nodeSess
  
  print ret
  return ()
  where
     y = fromGregorian 2001 02 19
     -- t = TimeOfDay 19 23 54
     -- lt = LocalTime y t


-- ======================================================================= --
-- DATETIME
-- ======================================================================= --

{-

mysql-sql> create table data_type_datetime (my_datetime datetime);
Query OK, 0 rows affected (0.03 sec)
mysql-sql> insert into data_type_datetime values ('2017-09-17 12:34:56');
Query OK, 1 row affected (0.01 sec)
mysql-sql> select * from data_type_datetime;
+---------------------+
| my_datetime         |
+---------------------+
| 2017-10-17 12:34:56 |
+---------------------+
1 row in set (0.00 sec)
mysql-sql>

flag = 0

-}

example06_03 :: IO ()
example06_03 = do
  putStrLn "start example6_03"
  nodeSess <- nodeSession 

  (meta, ret@(x:xs)) <- executeRawSqlMetaData "select * from data_type_datetime limit 1" nodeSess

  print meta
  print ret 
  let b = Seq.index x 0
  print $ getColLocalTime' b
  -- print $ (BL.length b )
  -- print $ (BinG.runGet example06_03_1 b)

  return ()

-- example06_03_1 :: BinG.Get String
-- example06_03_1 = do
--   y <- BinG.getWord16le 
--   m <- BinG.getWord8
--   d <- BinG.getWord8 
--   hh <- BinG.getWord8 
--   mm <- BinG.getWord8 
--   ss <- BinG.getWord8 
--   return $ (show (y-2048)) ++ "-" ++ (show m) ++ "-" ++ (show d) ++ " " ++ (show hh) ++ ":" ++ (show mm) ++ ":" ++ (show ss)

example06_03_Insert :: IO ()
example06_03_Insert = execSimpleTx "x_protocol_test" "root" "root" example06_03_Insert'

example06_03_Insert' :: NodeSession -> IO ()
example06_03_Insert' nodeSess = do

  ret <- updateSql "insert into data_type_datetime values (?)"  [XM.any lt] nodeSess
  
  print ret
  return ()
  where
     y = fromGregorian 2002 04 29
     t = TimeOfDay 19 23 54
     lt = LocalTime y t

-- ======================================================================= --
-- TIME
-- ======================================================================= --

{-
mysql-sql> create table data_type_time (my_time time);
Query OK, 0 rows affected (0.09 sec)

mysql-sql> insert into data_type_time values ("-112233");
Query OK, 1 row affected (0.01 sec)
mysql-sql> select * from data_type_time;
+-----------+
| time      |
+-----------+
| -11:22:33 |
+-----------+
1 row in set (0.00 sec)

mysql-sql> insert into data_type_time values ("112233");
Query OK, 1 row affected (0.01 sec)
mysql-sql> select * from data_type_time;
+----------+
| time     |
+----------+
| 11:22:33 |
+----------+
1 row in set (0.00 sec)
mysql-sql>
-}

example06_04 :: IO ()
example06_04 = do
  putStrLn "start example6_04"
  nodeSess <- nodeSession 

  (meta, ret@(x:xs)) <- executeRawSqlMetaData "select * from data_type_time limit 1" nodeSess

  print meta
  print ret 
  let b = Seq.index x 0
  print $ getColMysqlTime'  b
  -- print $ (BL.length b )
  -- print $ (SBinG.runBitGet (BL.toStrict b) example06_04_1)

  return ()

-- example06_04_1 :: SBinG.BitGet String
-- example06_04_1 = do
--   d1 <- SBinG.getBit
--   d2 <- SBinG.getBit
--   d3 <- SBinG.getBit
--   d4 <- SBinG.getBit
--   d5 <- SBinG.getBit
--   d6 <- SBinG.getBit
--   d7 <- SBinG.getBit
--   d8 <- SBinG.getBit -- sign  true -> negative
--   h <- SBinG.getAsWord8 8
--   m <- SBinG.getAsWord8 8 
--   s <- SBinG.getAsWord8 8
-- 
--   return $  (show d1) ++ " " ++  (show d2) ++ " " ++  (show d3) ++ " " ++  (show d4) ++ " " ++  (show d5) ++ " " ++  (show d6) ++ " " ++ (show d7) ++ " " ++ (show d8) ++ " " ++  (show h) ++ ":" ++ (show m) ++ ":" ++ (show s) -- ++ ":" ++ (show s1)
-- --
--
-- 1 bit sign    (1= non-negative, 0= negative)
-- 1 bit unused  (reserved for future extensions)
--10 bits hour   (0-838)
-- 6 bits minute (0-59) 
-- 6 bits second (0-59) 
-----------------------
--24 bits = 3 bytes

example06_04_Insert :: IO ()
example06_04_Insert = execSimpleTx "x_protocol_test" "root" "root" example06_04_Insert'

example06_04_Insert' :: NodeSession -> IO ()
example06_04_Insert' nodeSess = do

  ret <- updateSql "insert into data_type_time values (?)"  [XM.any (False, t)] nodeSess
  
  print ret
  return ()
  where
     -- y = fromGregorian 2001 02 19
     t = TimeOfDay 19 19 19
     -- lt = LocalTime y t


-- ======================================================================= --
-- TIMESTAMP 
-- ======================================================================= --

{-

mysql-sql> create table data_type_timestamp (my_timestamp timestamp);
Query OK, 0 rows affected (0.05 sec)
mysql-sql> insert into data_type_timestamp values ('2017-09-17 12:34:56');
Query OK, 1 row affected (0.02 sec)
mysql-sql> select * from data_type_timestamp;
+---------------------+
| my_timestamp        |
+---------------------+
| 2017-10-17 12:34:56 |
+---------------------+
1 row in set (0.00 sec)
mysql-sql>

flag = 1

-}

example06_05 :: IO ()
example06_05 = do
  putStrLn "start example06_05"
  nodeSess <- nodeSession 

  (meta, ret@(x:xs)) <- executeRawSqlMetaData "select * from data_type_timestamp limit 1" nodeSess

  print meta
  print ret 
  let b = Seq.index x 0
  print $ getColLocalTime' b
  -- print $ (BL.length b )
  -- print $ (BinG.runGet example06_05_1 b)

  return ()

-- example06_05_1 :: BinG.Get String
-- example06_05_1 = do
--   y <- BinG.getWord16le 
--   m <- BinG.getWord8
--   d <- BinG.getWord8 
--   hh <- BinG.getWord8 
--   mm <- BinG.getWord8 
--   ss <- BinG.getWord8 
--   return $ (show (y-2048)) ++ "-" ++ (show m) ++ "-" ++ (show d) ++ " " ++ (show hh) ++ ":" ++ (show mm) ++ ":" ++ (show ss)

example06_05_Insert :: IO ()
example06_05_Insert = do
  putStrLn "start example6_02"
  nodeSess <- nodeSession 

  ret <- updateSql "insert into data_type_timestamp values (?)"  [XM.any lt] nodeSess
  
  print ret
  return ()
  where
     y = fromGregorian 2023 09 17
     t = TimeOfDay 19 23 54
     lt = LocalTime y t

nodeSession :: IO NodeSession
nodeSession = openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

