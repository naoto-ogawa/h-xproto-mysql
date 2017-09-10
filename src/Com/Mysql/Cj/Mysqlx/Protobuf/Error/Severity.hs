{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Error.Severity (Severity(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Severity = ERROR
              | FATAL
              deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Severity

instance Prelude'.Bounded Severity where
  minBound = ERROR
  maxBound = FATAL

instance P'.Default Severity where
  defaultValue = ERROR

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Severity
toMaybe'Enum 0 = Prelude'.Just ERROR
toMaybe'Enum 1 = Prelude'.Just FATAL
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Severity where
  fromEnum ERROR = 0
  fromEnum FATAL = 1
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Error.Severity") .
      toMaybe'Enum
  succ ERROR = FATAL
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Error.Severity"
  pred FATAL = ERROR
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Error.Severity"

instance P'.Wire Severity where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB Severity

instance P'.MessageAPI msg' (msg' -> Severity) Severity where
  getVal m' f' = f' m'

instance P'.ReflectEnum Severity where
  reflectEnum = [(0, "ERROR", ERROR), (1, "FATAL", FATAL)]
  reflectEnumInfo _
   = P'.EnumInfo (P'.makePNF (P'.pack ".Mysqlx.Error.Severity") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Error"] "Severity")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Error", "Severity.hs"]
      [(0, "ERROR"), (1, "FATAL")]

instance P'.TextType Severity where
  tellT = P'.tellShow
  getT = P'.getRead