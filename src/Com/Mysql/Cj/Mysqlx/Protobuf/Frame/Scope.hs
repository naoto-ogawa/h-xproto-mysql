{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Frame.Scope (Scope(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Scope = GLOBAL
           | LOCAL
           deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Scope

instance Prelude'.Bounded Scope where
  minBound = GLOBAL
  maxBound = LOCAL

instance P'.Default Scope where
  defaultValue = GLOBAL

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Scope
toMaybe'Enum 1 = Prelude'.Just GLOBAL
toMaybe'Enum 2 = Prelude'.Just LOCAL
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Scope where
  fromEnum GLOBAL = 1
  fromEnum LOCAL = 2
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Frame.Scope") .
      toMaybe'Enum
  succ GLOBAL = LOCAL
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Frame.Scope"
  pred LOCAL = GLOBAL
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Frame.Scope"

instance P'.Wire Scope where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB Scope

instance P'.MessageAPI msg' (msg' -> Scope) Scope where
  getVal m' f' = f' m'

instance P'.ReflectEnum Scope where
  reflectEnum = [(1, "GLOBAL", GLOBAL), (2, "LOCAL", LOCAL)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Notice.Frame.Scope") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Frame"] "Scope")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Frame", "Scope.hs"]
      [(1, "GLOBAL"), (2, "LOCAL")]

instance P'.TextType Scope where
  tellT = P'.tellShow
  getT = P'.getRead