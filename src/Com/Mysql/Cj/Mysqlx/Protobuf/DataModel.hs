{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.DataModel (DataModel(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data DataModel = DOCUMENT
               | TABLE
               deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                         Prelude'.Generic)

instance P'.Mergeable DataModel

instance Prelude'.Bounded DataModel where
  minBound = DOCUMENT
  maxBound = TABLE

instance P'.Default DataModel where
  defaultValue = DOCUMENT

toMaybe'Enum :: Prelude'.Int -> P'.Maybe DataModel
toMaybe'Enum 1 = Prelude'.Just DOCUMENT
toMaybe'Enum 2 = Prelude'.Just TABLE
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum DataModel where
  fromEnum DOCUMENT = 1
  fromEnum TABLE = 2
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.DataModel") .
      toMaybe'Enum
  succ DOCUMENT = TABLE
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.DataModel"
  pred TABLE = DOCUMENT
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.DataModel"

instance P'.Wire DataModel where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB DataModel

instance P'.MessageAPI msg' (msg' -> DataModel) DataModel where
  getVal m' f' = f' m'

instance P'.ReflectEnum DataModel where
  reflectEnum = [(1, "DOCUMENT", DOCUMENT), (2, "TABLE", TABLE)]
  reflectEnumInfo _
   = P'.EnumInfo (P'.makePNF (P'.pack ".Mysqlx.Crud.DataModel") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf"] "DataModel")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "DataModel.hs"]
      [(1, "DOCUMENT"), (2, "TABLE")]

instance P'.TextType DataModel where
  tellT = P'.tellShow
  getT = P'.getRead