{-# LANGUAGE  ScopedTypeVariables #-}

module Example.Example02 where

import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM, bracket, catch)
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
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
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement
import DataBase.MySQLX.Util


--
-- create and drop collection
--
example2_01 :: IO ()
example2_01 = do
  putStrLn "start example2_01"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  createCollection "x_protocol_test" "foo_doc" nodeSess

  -- dropCollection   "x_protocol_test" "foo_doc" nodeSess

  closeNodeSession nodeSess
  putStrLn "end   example2_01"


--
-- Collection CRUD JSON Insert
--
example2_02 :: IO ()
example2_02 = do
  putStrLn "start example2_02"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  json1 <- insertUUIDIO "{\"name\" : \"Tom\" , \"age\" : 18 }"
  json2 <- insertUUIDIO "{\"name\" : \"Mike\" , \"age\" : 21 }"
  json3 <- insertUUIDIO "{\"name\" : \"Jone\" , \"age\" : 34 }"
  json4 <- insertUUIDIO "{\"name\" : \"Steve\", \"age\" : 55 }"
  json5 <- insertUUIDIO "{\"name\" : \"Nancy\", \"age\" : 55 }"

  let i1 = PB.defaultValue 
          `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
          `setDataModel` PDM.DOCUMENT 

  ret <- CRUD.insert (i1 `setTypedRow` [mkExpr2TypedRow' $ expr json1]) nodeSess
  print ret
  ret <- CRUD.insert (i1 `setTypedRow` [mkExpr2TypedRow' $ expr json2]) nodeSess
  print ret
  ret <- CRUD.insert (i1 `setTypedRow` [mkExpr2TypedRow' $ expr json3]) nodeSess
  print ret
  ret <- CRUD.insert (i1 `setTypedRow` [mkExpr2TypedRow' $ expr json4]) nodeSess
  print ret
  ret <- CRUD.insert (i1 `setTypedRow` [mkExpr2TypedRow' $ expr json5]) nodeSess
  print ret

  closeNodeSession nodeSess
  putStrLn "end   example2_02"


--
-- Collection CRUD Find All
--
example2_03 :: IO ()
example2_03 = do
  putStrLn "start example2_03"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  let f = PB.defaultValue `setCollection` (mkCollection "x_protocol_test" "foo_doc") `setDataModel` PDM.DOCUMENT :: PF.Find

  ret <- CRUD.find f nodeSess
  print ret

  return ()

  closeNodeSession nodeSess
  putStrLn "end   example2_03"

--
-- Collection CRUD Delete All
--
example2_04 :: IO ()
example2_04 = do
  putStrLn "start example2_04"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  let f = PB.defaultValue `setCollection` (mkCollection "x_protocol_test" "foo_doc") `setDataModel` PDM.DOCUMENT

  ret <- CRUD.delete f nodeSess
  print ret

  return ()

  closeNodeSession nodeSess
  putStrLn "end   example2_04"

--
-- Collection CRUD Find
--
example2_05 :: IO ()
example2_05 = do
  putStrLn "start example2_05"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "world_x", user = "root", password="root"}

  let f = PB.defaultValue 
          `setCollection` (mkCollection "world_x" "countryinfo") 
          `setDataModel`  PDM.DOCUMENT 
          `setCriteria`  (exprDocumentPathItem "name" @== expr "Mike" )

  ret <- CRUD.find f nodeSess
  print ret

  return ()

  closeNodeSession nodeSess
  putStrLn "end   example2_05"


--
-- Collection CRUD Delete
--
example2_06 :: IO ()
example2_06 = do
  putStrLn "start example2_06"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  let f = PB.defaultValue 
          `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
          `setDataModel`  PDM.DOCUMENT 
          `setCriteria`  (exprDocumentPathItem "name" @== expr "Mike" )

  ret <- CRUD.delete f nodeSess
  print ret

  return ()

  closeNodeSession nodeSess
  putStrLn "end   example2_06"

--
-- Collection CRUD Update 
--
example2_07 :: IO ()
example2_07 = do
  putStrLn "start example2_07"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  let f = PB.defaultValue 
          `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
          `setDataModel`  PDM.DOCUMENT 
          `setCriteria`   (exprDocumentPathItem "name" @== expr "Jone" )
          `setOperation`  [updateItemReplace "age" (999 :: Int)]

  ret <- CRUD.update f nodeSess
  print ret

  return ()

  closeNodeSession nodeSess
  putStrLn "end   example2_07"

--
-- Collection CRUD Find with a projection
--
example2_08 :: IO ()
example2_08 = do
  putStrLn "start example2_08"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  let f = PB.defaultValue 
          `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
          `setDataModel`  PDM.DOCUMENT 
          `setCriteria`   (exprDocumentPathItem "age" @> expr (30 :: Int))
          `setFields`     [mkProjection (exprDocumentPathItem "name") "name"]  -- Alias is needed, in case of DOCUMENT  --> TODO 

  ret <- CRUD.find f nodeSess
  print ret

  return ()

  closeNodeSession nodeSess
  putStrLn "end   example2_08"

--
-- Collection CRUD Find group by (select max(name) from foo_doc groupby age) 
--
example2_09 :: IO ()
example2_09 = do
  putStrLn "start example2_09"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  let f = PB.defaultValue 
          `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
          `setDataModel`  PDM.DOCUMENT 
          `setGrouping`   [exprDocumentPathItem "age"]
          `setFields`     [mkProjection (expr $ mkFunctionCall "max" [exprDocumentPathItem "name"]) "name"]  -- Alias is needed, in case of DOCUMENT  --> TODO 

  ret <- CRUD.find f nodeSess
  print $ "resultset size = " ++ (show $ length $ snd ret)
  print ret

  return ()

  closeNodeSession nodeSess
  putStrLn "end   example2_09"

--
-- Collection CRUD Find group by (select age, count(name) from foo_doc groupby age) 
--
example2_10 :: IO ()
example2_10 = do
  putStrLn "start example2_10"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  let f = PB.defaultValue 
          `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
          `setDataModel`  PDM.DOCUMENT 
          `setGrouping`   [exprDocumentPathItem "age"]
          `setFields`     [
                            mkProjection (exprDocumentPathItem "age") "age"
                           ,mkProjection (expr $ mkFunctionCall "count" [exprDocumentPathItem "name"]) "count"
                          ]  

  ret <- CRUD.find f nodeSess
  print $ "resultset size = " ++ (show $ length $ snd ret)
  print ret

  return ()

  closeNodeSession nodeSess
  putStrLn "end   example2_10"

