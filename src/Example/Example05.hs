
module Example.Example05 where

import  qualified  Com.Mysql.Cj.Mysqlx.Protobuf.Ok                                 as POk

import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 

import DataBase.MySQLX.Util
import DataBase.MySQLX.Model

example01 = do
  putStrLn "start Example02#example01"

  bin <- B.readFile "src/DataBase/MySQLX/Example/Example02_getIntFromLE.bin"
  print $ getIntFromLE bin -- 112

  putStrLn "end Example02#example01"

test_insertUUID = do
  putStrLn "start Example02#test_insertUUID"


  let a = (insertUUID "aaaa{bbbbbbb}" "***")
  putStrLn $ show $ "aaaa{\"id\" : ***, bbbbbbb}" == a 

  putStrLn "end   Example02#test_insertUUID"


{-
$ protoc-3/bin/protoc --decode_raw < src/DataBase/MySQLX/Example/dump_server_response_of_close.bin
1: "bye!"
-}
example_model_close :: IO POk.Ok
example_model_close = readObj "src/DataBase/MySQLX/Example/dump_server_response_of_close.bin"
  
