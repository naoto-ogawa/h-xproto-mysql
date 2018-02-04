{-# LANGUAGE  ScopedTypeVariables #-}

module Example.Example13 where

import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM, bracket, catch)
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Map.Strict      as Map
import qualified Data.Sequence        as Seq
import qualified Data.Text            as T
import qualified Data.Text.Encoding   as TE
import qualified Data.Word            as W

import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DataModel                          as PDM
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Delete                             as PD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find                               as PF

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB

-- my library
import DataBase.MySQLX.CRUD           as CRUD
import DataBase.MySQLX.Document
import DataBase.MySQLX.Exception
import DataBase.MySQLX.ExprParser
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement
import DataBase.MySQLX.Util


--
-- Collection CRUD Find
--
example13_01 :: IO ()
example13_01 = do
  putStrLn "start example13_01"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "world_x", user = "root", password="root", port=8000}

  let f = PB.defaultValue 
          `setCollection` (mkCollection "world_x" "city") 
          `setDataModel`  PDM.TABLE
          `setCriteria'`  "name = 'Kabul'" 

  ret <- CRUD.find f nodeSess
  pPrint_ ret

  closeNodeSession nodeSess
  putStrLn "end   example13_01"
  return ()

example13 :: IO ()
example13 = do 
  putStrLn $ "========== example 13 start =========="
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "world_x", user = "root", password="root", port=8000}
  -- example13_find_base nodeSess "find_01" find_01
  -- example13_find_base nodeSess "find_02" find_02
  -- example13_find_base nodeSess "find_03" find_03
  -- example13_find_base nodeSess "find_04" find_04
  -- example13_find_base nodeSess "find_05" find_05
  -- example13_find_base nodeSess "find_06" find_06
  -- example13_find_base nodeSess "find_07" find_07
  -- example13_find_base nodeSess "find_11" find_11
  -- example13_find_base nodeSess "find_12" find_12
  -- example13_find_base nodeSess "find_21" find_21
  example13_find_base nodeSess "find_31" find_31
  -- example13_find_base nodeSess "find_99" find_99
  closeNodeSession nodeSess
  putStrLn $ "========== example 13   end =========="
  return ()

example13_find_base :: NodeSession -> String -> PF.Find -> IO ()
example13_find_base nodeSess name f = do
  putStrLn $ "----- start " ++ name
  ret <- CRUD.find f nodeSess
  pPrint_ ret
  putStrLn $ "----- end   " ++ name
  return ()

find_base :: PF.Find
find_base = getTableModel 
          `setCollection` (mkCollection "world_x" "city") 

find_01 :: PF.Find
find_01 = find_base 
          `setCriteria'`  "name = 'Kabul'" 
          
find_02 :: PF.Find
find_02 = find_base 
          `setCriteria'`  "name == 'Kabul'" 

find_03 :: PF.Find
find_03 = find_base 
          `setCriteria'`  " 1 < id && id < 3" 

find_04 :: PF.Find
find_04 = find_base 
          `setCriteria'`  " id < 1 and id < 3" 

find_05 :: PF.Find
find_05 = find_base 
          `setCriteria'`  " id = 1 + 1" 

find_06 :: PF.Find
find_06 = find_base 
          `setCriteria'`  " id = ?" 
          `setArgs`       [scalar (3 :: Int)]

find_07 :: PF.Find
find_07 = find_base 
          `setCriteria'`  " id = :x" 
          `setArgs`       [scalar (3 :: Int)]

find_11 :: PF.Find
find_11 = find_base 
          `setCriteriaBind ` (" id = :x", map) 
  where map = Map.insert "x" (scalar (3 :: Int)) Map.empty  
  
find_12 :: PF.Find
find_12 = find_base 
          `setCriteriaBind ` (" id < :id and District == :dist", map) 
  where map = 
          Map.insert "dist" (scalar "Kocaeli")  $ 
          Map.insert "id"   (scalar (3380 :: Int)) $
          Map.empty  

find_21 :: PF.Find
find_21 = find_01 
          `setFields'` "Name, CountryCode as CD"
          
find_31 :: PF.Find
find_31 = find_base 
          `setCriteria'`  " id < 10" 
          `setOrder'`     "CountryCode, ID desc"
{-

mysql-js> city.select().where("id < 10").orderBy(["CountryCode", "ID desc" ]);
+----+----------------+-------------+---------------+-------------------------+
| ID | Name           | CountryCode | District      | Info                    |
+----+----------------+-------------+---------------+-------------------------+
|  4 | Mazar-e-Sharif | AFG         | Balkh         | {"Population": 127800}  |
|  3 | Herat          | AFG         | Herat         | {"Population": 186800}  |
|  2 | Qandahar       | AFG         | Qandahar      | {"Population": 237500}  |
|  1 | Kabul          | AFG         | Kabol         | {"Population": 1780000} |
|  9 | Eindhoven      | NLD         | Noord-Brabant | {"Population": 201843}  |
|  8 | Utrecht        | NLD         | Utrecht       | {"Population": 234323}  |
|  7 | Haag           | NLD         | Zuid-Holland  | {"Population": 440900}  |
|  6 | Rotterdam      | NLD         | Zuid-Holland  | {"Population": 593321}  |
|  5 | Amsterdam      | NLD         | Noord-Holland | {"Population": 731200}  |
+----+----------------+-------------+---------------+-------------------------+
9 rows in set (0.01 sec)

-} 
find_99 :: PF.Find
find_99 = find_base 
          `setCriteriaBind ` (
            "   id = :id1 || "
           ++ " id = :id2 || "
           ++ " id = :id3 || "
           ++ " id = :id4 || "
           ++ " id = :id5 || "
           ++ " id = :id6 || "
           ++ " id = :id7 || "
           ++ " id = :id8 || "
           ++ " id = :id9    "
           , map) 
  where map = 
          Map.insert "id1"   (scalar (1     :: Int)) $
          Map.insert "id2"   (scalar (-1    :: Int)) $
          Map.insert "id3"   (scalar (30    :: Int)) $
          Map.insert "id4"   (scalar (-30   :: Int)) $
          Map.insert "id5"   (scalar (300   :: Int)) $
          Map.insert "id6"   (scalar (-300  :: Int)) $
          Map.insert "id7"   (scalar (3380  :: Int)) $
          Map.insert "id8"   (scalar (-3380 :: Int)) $
          Map.insert "id9"   (scalar (9999  :: Int)) $
          Map.empty

{-
mysql-sql> select * from city where District='Kocaeli';
+------+-----------------+-------------+----------+------------------------+
| ID   | Name            | CountryCode | District | Info                   |
+------+-----------------+-------------+----------+------------------------+
| 3372 | Gebze           | TUR         | Kocaeli  | {"Population": 264170} |
| 3381 | Izmit (Kocaeli) | TUR         | Kocaeli  | {"Population": 210068} |
+------+-----------------+-------------+----------+------------------------+
2 rows in set (0.01 sec)
-}

