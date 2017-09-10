{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Any.Type (Type(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Type = SCALAR
          | OBJECT
          | ARRAY
          deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Type

instance Prelude'.Bounded Type where
  minBound = SCALAR
  maxBound = ARRAY

instance P'.Default Type where
  defaultValue = SCALAR

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Type
toMaybe'Enum 1 = Prelude'.Just SCALAR
toMaybe'Enum 2 = Prelude'.Just OBJECT
toMaybe'Enum 3 = Prelude'.Just ARRAY
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Type where
  fromEnum SCALAR = 1
  fromEnum OBJECT = 2
  fromEnum ARRAY = 3
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Any.Type") .
      toMaybe'Enum
  succ SCALAR = OBJECT
  succ OBJECT = ARRAY
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Any.Type"
  pred OBJECT = SCALAR
  pred ARRAY = OBJECT
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Any.Type"

instance P'.Wire Type where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB Type

instance P'.MessageAPI msg' (msg' -> Type) Type where
  getVal m' f' = f' m'

instance P'.ReflectEnum Type where
  reflectEnum = [(1, "SCALAR", SCALAR), (2, "OBJECT", OBJECT), (3, "ARRAY", ARRAY)]
  reflectEnumInfo _
   = P'.EnumInfo (P'.makePNF (P'.pack ".Mysqlx.Datatypes.Any.Type") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Any"] "Type")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Any", "Type.hs"]
      [(1, "SCALAR"), (2, "OBJECT"), (3, "ARRAY")]

instance P'.TextType Type where
  tellT = P'.tellShow
  getT = P'.getRead