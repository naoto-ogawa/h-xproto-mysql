module Example.Example11 where

-- general, standard library
import qualified Data.ByteString.Lazy as BL 
import           Data.Sequence        as Seq
import           Data.Word
import           Text.Pretty.Simple

-- protocolbuffers
import qualified Text.ProtocolBuffers                as PB

-- protocol buffer library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DataModel                          as PDM
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Expr                               as PEx
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find                               as PF
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.FunctionCall                       as PFC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Limit                              as PL

-- my library
import DataBase.MySQLX.CRUD           as CRUD
import DataBase.MySQLX.Exception
import DataBase.MySQLX.Functions
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.ResultSet
import DataBase.MySQLX.Statement
import DataBase.MySQLX.Util

{-

mysql-sql> desc actor;
+-------------+----------------------+------+-----+-------------------+-----------------------------+
| Field       | Type                 | Null | Key | Default           | Extra                       |
+-------------+----------------------+------+-----+-------------------+-----------------------------+
| actor_id    | smallint(5) unsigned | NO   | PRI | null              | auto_increment              |
| first_name  | varchar(45)          | NO   |     | null              |                             |
| last_name   | varchar(45)          | NO   | MUL | null              |                             |
| last_update | timestamp            | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP |
+-------------+----------------------+------+-----+-------------------+-----------------------------+

-}

example11_sakila_actor = do
   execSimpleTx "sakila" "root" "root" test
   where
    test = \nodeSess -> do
      (meta, ret@(x:xs)) <- executeRawSqlMetaData "select * from actor limit 1" nodeSess
      pPrint meta
      print $ "getSizeRs " ++ (show $ getSizeRs meta)
      print $ "getColumnsNameTypeRs  " ++ (show $ getColumnsNameTypeRs meta) 
      print $ "getColumnIdxByNameRs actor_id    " ++ (show $ getColumnIdxByNameRs' meta "actor_id") 
      print $ "getColumnIdxByNameRs first_name  " ++ (show $ getColumnIdxByNameRs' meta "first_name") 
      print $ "getColumnIdxByNameRs last_name   " ++ (show $ getColumnIdxByNameRs' meta "last_name") 
      print $ "getColumnIdxByNameRs last_update " ++ (show $ getColumnIdxByNameRs' meta "last_update") 
      print $ "getColumnNameTextRs 0 " ++ (show $ getColumnNameTextRs meta 0) 
      print $ "getColumnNameTextRs 1 " ++ (show $ getColumnNameTextRs meta 1) 
      print $ "getColumnNameTextRs 2 " ++ (show $ getColumnNameTextRs meta 2) 
      print $ "getColumnNameTextRs 3 " ++ (show $ getColumnNameTextRs meta 3) 
      
      return ret

--     ResultSetMetaData
--    ,getSizeRs
--    ,getColumnTypeRs
--    ,getColumnTypesRs
--    ,getColumnTypeByNameRs
--    ,getColumnTypeByNameRs'
--    ,getColumnNamesRs
--    ,getColumnNamesTextRs
--    ,getColumnNameTextRs
--    ,getColumnIdxByNameRs
--    ,getColumnIdxByNameRs'
--    ,getOriginalNameRs
--    ,getTableRs
--    ,getOriginalTableRS
--    ,getSchemaRs
--    ,getCatalogRs
--    ,getColumnCollationRs
--    ,getColumnFractionalDigitsRs
--    ,getColumnLengthRs
--    ,getColumnFlagsRs
--    ,getColumnContentTypeRs
 
