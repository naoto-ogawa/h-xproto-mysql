{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Scalar.Type (Type(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Type = V_SINT
          | V_UINT
          | V_NULL
          | V_OCTETS
          | V_DOUBLE
          | V_FLOAT
          | V_BOOL
          | V_STRING
          deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Type

instance Prelude'.Bounded Type where
  minBound = V_SINT
  maxBound = V_STRING

instance P'.Default Type where
  defaultValue = V_SINT

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Type
toMaybe'Enum 1 = Prelude'.Just V_SINT
toMaybe'Enum 2 = Prelude'.Just V_UINT
toMaybe'Enum 3 = Prelude'.Just V_NULL
toMaybe'Enum 4 = Prelude'.Just V_OCTETS
toMaybe'Enum 5 = Prelude'.Just V_DOUBLE
toMaybe'Enum 6 = Prelude'.Just V_FLOAT
toMaybe'Enum 7 = Prelude'.Just V_BOOL
toMaybe'Enum 8 = Prelude'.Just V_STRING
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Type where
  fromEnum V_SINT = 1
  fromEnum V_UINT = 2
  fromEnum V_NULL = 3
  fromEnum V_OCTETS = 4
  fromEnum V_DOUBLE = 5
  fromEnum V_FLOAT = 6
  fromEnum V_BOOL = 7
  fromEnum V_STRING = 8
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Scalar.Type") .
      toMaybe'Enum
  succ V_SINT = V_UINT
  succ V_UINT = V_NULL
  succ V_NULL = V_OCTETS
  succ V_OCTETS = V_DOUBLE
  succ V_DOUBLE = V_FLOAT
  succ V_FLOAT = V_BOOL
  succ V_BOOL = V_STRING
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Scalar.Type"
  pred V_UINT = V_SINT
  pred V_NULL = V_UINT
  pred V_OCTETS = V_NULL
  pred V_DOUBLE = V_OCTETS
  pred V_FLOAT = V_DOUBLE
  pred V_BOOL = V_FLOAT
  pred V_STRING = V_BOOL
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Scalar.Type"

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
   = [(1, "V_SINT", V_SINT), (2, "V_UINT", V_UINT), (3, "V_NULL", V_NULL), (4, "V_OCTETS", V_OCTETS), (5, "V_DOUBLE", V_DOUBLE),
      (6, "V_FLOAT", V_FLOAT), (7, "V_BOOL", V_BOOL), (8, "V_STRING", V_STRING)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Datatypes.Scalar.Type") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Scalar"] "Type")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Scalar", "Type.hs"]
      [(1, "V_SINT"), (2, "V_UINT"), (3, "V_NULL"), (4, "V_OCTETS"), (5, "V_DOUBLE"), (6, "V_FLOAT"), (7, "V_BOOL"),
       (8, "V_STRING")]

instance P'.TextType Type where
  tellT = P'.tellShow
  getT = P'.getRead