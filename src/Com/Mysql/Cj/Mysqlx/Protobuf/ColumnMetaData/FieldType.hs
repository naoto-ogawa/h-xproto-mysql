{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType (FieldType(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data FieldType = SINT
               | UINT
               | DOUBLE
               | FLOAT
               | BYTES
               | TIME
               | DATETIME
               | SET
               | ENUM
               | BIT
               | DECIMAL
               deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                         Prelude'.Generic)

instance P'.Mergeable FieldType

instance Prelude'.Bounded FieldType where
  minBound = SINT
  maxBound = DECIMAL

instance P'.Default FieldType where
  defaultValue = SINT

toMaybe'Enum :: Prelude'.Int -> P'.Maybe FieldType
toMaybe'Enum 1 = Prelude'.Just SINT
toMaybe'Enum 2 = Prelude'.Just UINT
toMaybe'Enum 5 = Prelude'.Just DOUBLE
toMaybe'Enum 6 = Prelude'.Just FLOAT
toMaybe'Enum 7 = Prelude'.Just BYTES
toMaybe'Enum 10 = Prelude'.Just TIME
toMaybe'Enum 12 = Prelude'.Just DATETIME
toMaybe'Enum 15 = Prelude'.Just SET
toMaybe'Enum 16 = Prelude'.Just ENUM
toMaybe'Enum 17 = Prelude'.Just BIT
toMaybe'Enum 18 = Prelude'.Just DECIMAL
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum FieldType where
  fromEnum SINT = 1
  fromEnum UINT = 2
  fromEnum DOUBLE = 5
  fromEnum FLOAT = 6
  fromEnum BYTES = 7
  fromEnum TIME = 10
  fromEnum DATETIME = 12
  fromEnum SET = 15
  fromEnum ENUM = 16
  fromEnum BIT = 17
  fromEnum DECIMAL = 18
  toEnum
   = P'.fromMaybe
      (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType")
      . toMaybe'Enum
  succ SINT = UINT
  succ UINT = DOUBLE
  succ DOUBLE = FLOAT
  succ FLOAT = BYTES
  succ BYTES = TIME
  succ TIME = DATETIME
  succ DATETIME = SET
  succ SET = ENUM
  succ ENUM = BIT
  succ BIT = DECIMAL
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType"
  pred UINT = SINT
  pred DOUBLE = UINT
  pred FLOAT = DOUBLE
  pred BYTES = FLOAT
  pred TIME = BYTES
  pred DATETIME = TIME
  pred SET = DATETIME
  pred ENUM = SET
  pred BIT = ENUM
  pred DECIMAL = BIT
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType"

instance P'.Wire FieldType where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB FieldType

instance P'.MessageAPI msg' (msg' -> FieldType) FieldType where
  getVal m' f' = f' m'

instance P'.ReflectEnum FieldType where
  reflectEnum
   = [(1, "SINT", SINT), (2, "UINT", UINT), (5, "DOUBLE", DOUBLE), (6, "FLOAT", FLOAT), (7, "BYTES", BYTES), (10, "TIME", TIME),
      (12, "DATETIME", DATETIME), (15, "SET", SET), (16, "ENUM", ENUM), (17, "BIT", BIT), (18, "DECIMAL", DECIMAL)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Resultset.ColumnMetaData.FieldType") []
        ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ColumnMetaData"]
        "FieldType")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ColumnMetaData", "FieldType.hs"]
      [(1, "SINT"), (2, "UINT"), (5, "DOUBLE"), (6, "FLOAT"), (7, "BYTES"), (10, "TIME"), (12, "DATETIME"), (15, "SET"),
       (16, "ENUM"), (17, "BIT"), (18, "DECIMAL")]

instance P'.TextType FieldType where
  tellT = P'.tellShow
  getT = P'.getRead