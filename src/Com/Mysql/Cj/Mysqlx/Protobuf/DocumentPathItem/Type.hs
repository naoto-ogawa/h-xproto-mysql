{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.DocumentPathItem.Type (Type(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Type = MEMBER
          | MEMBER_ASTERISK
          | ARRAY_INDEX
          | ARRAY_INDEX_ASTERISK
          | DOUBLE_ASTERISK
          deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Type

instance Prelude'.Bounded Type where
  minBound = MEMBER
  maxBound = DOUBLE_ASTERISK

instance P'.Default Type where
  defaultValue = MEMBER

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Type
toMaybe'Enum 1 = Prelude'.Just MEMBER
toMaybe'Enum 2 = Prelude'.Just MEMBER_ASTERISK
toMaybe'Enum 3 = Prelude'.Just ARRAY_INDEX
toMaybe'Enum 4 = Prelude'.Just ARRAY_INDEX_ASTERISK
toMaybe'Enum 5 = Prelude'.Just DOUBLE_ASTERISK
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Type where
  fromEnum MEMBER = 1
  fromEnum MEMBER_ASTERISK = 2
  fromEnum ARRAY_INDEX = 3
  fromEnum ARRAY_INDEX_ASTERISK = 4
  fromEnum DOUBLE_ASTERISK = 5
  toEnum
   = P'.fromMaybe
      (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.DocumentPathItem.Type")
      . toMaybe'Enum
  succ MEMBER = MEMBER_ASTERISK
  succ MEMBER_ASTERISK = ARRAY_INDEX
  succ ARRAY_INDEX = ARRAY_INDEX_ASTERISK
  succ ARRAY_INDEX_ASTERISK = DOUBLE_ASTERISK
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.DocumentPathItem.Type"
  pred MEMBER_ASTERISK = MEMBER
  pred ARRAY_INDEX = MEMBER_ASTERISK
  pred ARRAY_INDEX_ASTERISK = ARRAY_INDEX
  pred DOUBLE_ASTERISK = ARRAY_INDEX_ASTERISK
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.DocumentPathItem.Type"

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
  reflectEnum
   = [(1, "MEMBER", MEMBER), (2, "MEMBER_ASTERISK", MEMBER_ASTERISK), (3, "ARRAY_INDEX", ARRAY_INDEX),
      (4, "ARRAY_INDEX_ASTERISK", ARRAY_INDEX_ASTERISK), (5, "DOUBLE_ASTERISK", DOUBLE_ASTERISK)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Expr.DocumentPathItem.Type") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "DocumentPathItem"]
        "Type")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "DocumentPathItem", "Type.hs"]
      [(1, "MEMBER"), (2, "MEMBER_ASTERISK"), (3, "ARRAY_INDEX"), (4, "ARRAY_INDEX_ASTERISK"), (5, "DOUBLE_ASTERISK")]

instance P'.TextType Type where
  tellT = P'.tellShow
  getT = P'.getRead