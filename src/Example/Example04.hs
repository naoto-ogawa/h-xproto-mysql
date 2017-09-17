{-# LANGUAGE DeriveGeneric, ScopedTypeVariables, TemplateHaskell,  TypeInType, TypeFamilies, KindSignatures, DataKinds, TypeOperators, GADTs, TypeSynonymInstances, FlexibleInstances #-}

module Example.Example04 where

import Language.Haskell.TH
import Language.Haskell.TH.Syntax

import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM, bracket, catch)
import qualified Data.Aeson           as JSON 
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Int             as I
import Data.Kind           
import qualified Data.Sequence        as Seq
import qualified Data.Text            as T
import qualified Data.Text.Encoding   as TE
import qualified Data.Word            as W

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

data BookInfo = BookInfo {
      isbn   :: String
    , title  :: String
    , author :: String
    , currentlyReadingPage  :: Int
    } deriving (Generic, Show)

instance JSON.FromJSON BookInfo

--
-- JSON Sample : find
--
example4_01 :: IO ()
example4_01 = do
  putStrLn "start example4_01"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  let f = PB.defaultValue 
          `setCollection` (mkCollection "x_protocol_test" "mydoc") 
          `setDataModel`  PDM.DOCUMENT 
          `setCriteria`  (exprDocumentPathItem "isbn" @== expr "XXXX-001" )

  (_, ret@(x:xs)) <- CRUD.find f nodeSess
  let doc = (JSON.eitherDecode' $ cutNull $ Seq.index x 0) :: Either String BookInfo
  case doc of
    Right x -> do 
      print x
    Left s -> do 
      print s

  return ()

--
-- JSON Sample : insert
--

{-

idea

toJSON :: a -> Value

instance Exprable JSONT.Value where 
  expr :: Value -> Expr

-}


{-
mysql-sql> select * from mydoc;
| doc| _id|
| {"_id": "cbbe7ba36cdb82354db8ec5af29e1f17", "isbn": "XXXX-001", "title": "Effi Briest", "author": "Theodor Fontane", "currentlyReadingPage": 42} | cbbe7ba36cdb82354db8ec5af29e1f17 |
| {"_id": "ebfbf3fac6d6b63d42b75579e6dc4e14", "isbn": "XXXX-003", "title": "ABC", "author": "XYZ", "currentlyReadingPage": 100}                    | ebfbf3fac6d6b63d42b75579e6dc4e14 |
| {"_id": "efe556667944a82142d3151e5b76a7a6", "isbn": "XXXX-002", "title": "Haruki Murakami", "author": "Norway Wood", "currentlyReadingPage": 1}  | efe556667944a82142d3151e5b76a7a6 |
-}

