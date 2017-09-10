{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Expr (Expr) where
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Expr

instance P'.MessageAPI msg' (msg' -> Expr) Expr

instance Prelude'.Show Expr

instance Prelude'.Eq Expr

instance Prelude'.Ord Expr

instance Prelude'.Typeable Expr

instance Prelude'.Data Expr

instance Prelude'.Generic Expr

instance P'.Mergeable Expr

instance P'.Default Expr

instance P'.Wire Expr

instance P'.GPB Expr

instance P'.ReflectDescriptor Expr

instance P'.TextType Expr

instance P'.TextMsg Expr