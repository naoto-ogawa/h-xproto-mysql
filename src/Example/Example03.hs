{-# LANGUAGE  ScopedTypeVariables, TemplateHaskell #-}
{-# LANGUAGE TypeInType, TypeFamilies, KindSignatures, DataKinds, TypeOperators, GADTs, TypeSynonymInstances, FlexibleInstances  #-}

module Example.Example03 where

import Language.Haskell.TH
import Language.Haskell.TH.Syntax

import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM, bracket, catch)
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Int             as I
import Data.Kind           
import qualified Data.Sequence        as Seq
import qualified Data.Text            as T
import qualified Data.Text.Encoding   as TE
import qualified Data.Word            as W

import qualified  Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD

-- my library
import DataBase.MySQLX.Exception
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement
import DataBase.MySQLX.TH
import DataBase.MySQLX.Util
import DataBase.MySQLX.Util

import Example.Example03_data

--
-- Select interface from a row to a record object by Template Haskell.
-- 

example03_1 :: IO ()
example03_1 = do
  putStrLn "start example03_1"
  node <- openNodeSession $ defaultNodeSesssionInfo {database = "world_x", user = "root", password="root"}
  debug $ "node=" ++ (show node)
  
  select1 node

  closeNodeSession node
  putStrLn "end example03_1"

select1 :: NodeSession -> IO () 
select1 node = do
  print "start select 1 ---------- "
  ret@(x:xs) <- executeRawSql "select * from city limit 2" node
  print ( $(retrieveRow ''MyRecord) x )
  print "end   select 1 ---------- "

