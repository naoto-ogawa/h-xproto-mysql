{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Warning.Level (Level(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Level = NOTE
           | WARNING
           | ERROR
           deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Level

instance Prelude'.Bounded Level where
  minBound = NOTE
  maxBound = ERROR

instance P'.Default Level where
  defaultValue = NOTE

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Level
toMaybe'Enum 1 = Prelude'.Just NOTE
toMaybe'Enum 2 = Prelude'.Just WARNING
toMaybe'Enum 3 = Prelude'.Just ERROR
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Level where
  fromEnum NOTE = 1
  fromEnum WARNING = 2
  fromEnum ERROR = 3
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Warning.Level") .
      toMaybe'Enum
  succ NOTE = WARNING
  succ WARNING = ERROR
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Warning.Level"
  pred WARNING = NOTE
  pred ERROR = WARNING
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Warning.Level"

instance P'.Wire Level where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB Level

instance P'.MessageAPI msg' (msg' -> Level) Level where
  getVal m' f' = f' m'

instance P'.ReflectEnum Level where
  reflectEnum = [(1, "NOTE", NOTE), (2, "WARNING", WARNING), (3, "ERROR", ERROR)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Notice.Warning.Level") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Warning"] "Level")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Warning", "Level.hs"]
      [(1, "NOTE"), (2, "WARNING"), (3, "ERROR")]

instance P'.TextType Level where
  tellT = P'.tellShow
  getT = P'.getRead