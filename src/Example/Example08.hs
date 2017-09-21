{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables, TemplateHaskell,  TypeInType, TypeFamilies, KindSignatures, DataKinds, TypeOperators, GADTs, TypeSynonymInstances, FlexibleInstances #-}

{-# LANGUAGE DuplicateRecordFields #-}

module Example.Example08 where

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
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert                             as PI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find                               as PF

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
-- Insert a document by using Aeson.
-- ======================================================================= --

data Person = Person {
      _id  :: String
    , name :: T.Text
    , age  :: Int
    } deriving (Generic, Show)
    
instance JSON.ToJSON Person

data Person' = Person' {
      name :: T.Text
    , age  :: Int
    } deriving (Generic, Show)
    
instance JSON.ToJSON Person'

example08_01 :: IO ()
example08_01 = do
  putStrLn "start example08_01"
  nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  json <- insertJSONUUID . JSON.toJSON $ Person' "ogawa" 28 
   
  let i1 = (PB.defaultValue :: PI.Insert)
          `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
          `setDataModel` PDM.DOCUMENT 
--          `setTypedRow'` [expr $  JSON.toJSON $  Person "aaaa" "ogawa" 27] 
         `setTypedRow'` [expr json] 

  ret <- CRUD.insert i1 nodeSess
  print ret

  putStrLn "end   example08_01"
  return ()


