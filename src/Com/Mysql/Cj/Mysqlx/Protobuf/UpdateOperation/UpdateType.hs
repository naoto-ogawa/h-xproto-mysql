{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.UpdateOperation.UpdateType (UpdateType(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data UpdateType = SET
                | ITEM_REMOVE
                | ITEM_SET
                | ITEM_REPLACE
                | ITEM_MERGE
                | ARRAY_INSERT
                | ARRAY_APPEND
                deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                          Prelude'.Generic)

instance P'.Mergeable UpdateType

instance Prelude'.Bounded UpdateType where
  minBound = SET
  maxBound = ARRAY_APPEND

instance P'.Default UpdateType where
  defaultValue = SET

toMaybe'Enum :: Prelude'.Int -> P'.Maybe UpdateType
toMaybe'Enum 1 = Prelude'.Just SET
toMaybe'Enum 2 = Prelude'.Just ITEM_REMOVE
toMaybe'Enum 3 = Prelude'.Just ITEM_SET
toMaybe'Enum 4 = Prelude'.Just ITEM_REPLACE
toMaybe'Enum 5 = Prelude'.Just ITEM_MERGE
toMaybe'Enum 6 = Prelude'.Just ARRAY_INSERT
toMaybe'Enum 7 = Prelude'.Just ARRAY_APPEND
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum UpdateType where
  fromEnum SET = 1
  fromEnum ITEM_REMOVE = 2
  fromEnum ITEM_SET = 3
  fromEnum ITEM_REPLACE = 4
  fromEnum ITEM_MERGE = 5
  fromEnum ARRAY_INSERT = 6
  fromEnum ARRAY_APPEND = 7
  toEnum
   = P'.fromMaybe
      (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.UpdateOperation.UpdateType")
      . toMaybe'Enum
  succ SET = ITEM_REMOVE
  succ ITEM_REMOVE = ITEM_SET
  succ ITEM_SET = ITEM_REPLACE
  succ ITEM_REPLACE = ITEM_MERGE
  succ ITEM_MERGE = ARRAY_INSERT
  succ ARRAY_INSERT = ARRAY_APPEND
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.UpdateOperation.UpdateType"
  pred ITEM_REMOVE = SET
  pred ITEM_SET = ITEM_REMOVE
  pred ITEM_REPLACE = ITEM_SET
  pred ITEM_MERGE = ITEM_REPLACE
  pred ARRAY_INSERT = ITEM_MERGE
  pred ARRAY_APPEND = ARRAY_INSERT
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.UpdateOperation.UpdateType"

instance P'.Wire UpdateType where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB UpdateType

instance P'.MessageAPI msg' (msg' -> UpdateType) UpdateType where
  getVal m' f' = f' m'

instance P'.ReflectEnum UpdateType where
  reflectEnum
   = [(1, "SET", SET), (2, "ITEM_REMOVE", ITEM_REMOVE), (3, "ITEM_SET", ITEM_SET), (4, "ITEM_REPLACE", ITEM_REPLACE),
      (5, "ITEM_MERGE", ITEM_MERGE), (6, "ARRAY_INSERT", ARRAY_INSERT), (7, "ARRAY_APPEND", ARRAY_APPEND)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Crud.UpdateOperation.UpdateType") []
        ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "UpdateOperation"]
        "UpdateType")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "UpdateOperation", "UpdateType.hs"]
      [(1, "SET"), (2, "ITEM_REMOVE"), (3, "ITEM_SET"), (4, "ITEM_REPLACE"), (5, "ITEM_MERGE"), (6, "ARRAY_INSERT"),
       (7, "ARRAY_APPEND")]

instance P'.TextType UpdateType where
  tellT = P'.tellShow
  getT = P'.getRead