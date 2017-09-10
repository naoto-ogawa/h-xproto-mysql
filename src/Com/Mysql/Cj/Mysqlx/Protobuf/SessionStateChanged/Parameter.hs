{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.SessionStateChanged.Parameter (Parameter(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Parameter = CURRENT_SCHEMA
               | ACCOUNT_EXPIRED
               | GENERATED_INSERT_ID
               | ROWS_AFFECTED
               | ROWS_FOUND
               | ROWS_MATCHED
               | TRX_COMMITTED
               | TRX_ROLLEDBACK
               | PRODUCED_MESSAGE
               | CLIENT_ID_ASSIGNED
               deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                         Prelude'.Generic)

instance P'.Mergeable Parameter

instance Prelude'.Bounded Parameter where
  minBound = CURRENT_SCHEMA
  maxBound = CLIENT_ID_ASSIGNED

instance P'.Default Parameter where
  defaultValue = CURRENT_SCHEMA

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Parameter
toMaybe'Enum 1 = Prelude'.Just CURRENT_SCHEMA
toMaybe'Enum 2 = Prelude'.Just ACCOUNT_EXPIRED
toMaybe'Enum 3 = Prelude'.Just GENERATED_INSERT_ID
toMaybe'Enum 4 = Prelude'.Just ROWS_AFFECTED
toMaybe'Enum 5 = Prelude'.Just ROWS_FOUND
toMaybe'Enum 6 = Prelude'.Just ROWS_MATCHED
toMaybe'Enum 7 = Prelude'.Just TRX_COMMITTED
toMaybe'Enum 9 = Prelude'.Just TRX_ROLLEDBACK
toMaybe'Enum 10 = Prelude'.Just PRODUCED_MESSAGE
toMaybe'Enum 11 = Prelude'.Just CLIENT_ID_ASSIGNED
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Parameter where
  fromEnum CURRENT_SCHEMA = 1
  fromEnum ACCOUNT_EXPIRED = 2
  fromEnum GENERATED_INSERT_ID = 3
  fromEnum ROWS_AFFECTED = 4
  fromEnum ROWS_FOUND = 5
  fromEnum ROWS_MATCHED = 6
  fromEnum TRX_COMMITTED = 7
  fromEnum TRX_ROLLEDBACK = 9
  fromEnum PRODUCED_MESSAGE = 10
  fromEnum CLIENT_ID_ASSIGNED = 11
  toEnum
   = P'.fromMaybe
      (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.SessionStateChanged.Parameter")
      . toMaybe'Enum
  succ CURRENT_SCHEMA = ACCOUNT_EXPIRED
  succ ACCOUNT_EXPIRED = GENERATED_INSERT_ID
  succ GENERATED_INSERT_ID = ROWS_AFFECTED
  succ ROWS_AFFECTED = ROWS_FOUND
  succ ROWS_FOUND = ROWS_MATCHED
  succ ROWS_MATCHED = TRX_COMMITTED
  succ TRX_COMMITTED = TRX_ROLLEDBACK
  succ TRX_ROLLEDBACK = PRODUCED_MESSAGE
  succ PRODUCED_MESSAGE = CLIENT_ID_ASSIGNED
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.SessionStateChanged.Parameter"
  pred ACCOUNT_EXPIRED = CURRENT_SCHEMA
  pred GENERATED_INSERT_ID = ACCOUNT_EXPIRED
  pred ROWS_AFFECTED = GENERATED_INSERT_ID
  pred ROWS_FOUND = ROWS_AFFECTED
  pred ROWS_MATCHED = ROWS_FOUND
  pred TRX_COMMITTED = ROWS_MATCHED
  pred TRX_ROLLEDBACK = TRX_COMMITTED
  pred PRODUCED_MESSAGE = TRX_ROLLEDBACK
  pred CLIENT_ID_ASSIGNED = PRODUCED_MESSAGE
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.SessionStateChanged.Parameter"

instance P'.Wire Parameter where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB Parameter

instance P'.MessageAPI msg' (msg' -> Parameter) Parameter where
  getVal m' f' = f' m'

instance P'.ReflectEnum Parameter where
  reflectEnum
   = [(1, "CURRENT_SCHEMA", CURRENT_SCHEMA), (2, "ACCOUNT_EXPIRED", ACCOUNT_EXPIRED),
      (3, "GENERATED_INSERT_ID", GENERATED_INSERT_ID), (4, "ROWS_AFFECTED", ROWS_AFFECTED), (5, "ROWS_FOUND", ROWS_FOUND),
      (6, "ROWS_MATCHED", ROWS_MATCHED), (7, "TRX_COMMITTED", TRX_COMMITTED), (9, "TRX_ROLLEDBACK", TRX_ROLLEDBACK),
      (10, "PRODUCED_MESSAGE", PRODUCED_MESSAGE), (11, "CLIENT_ID_ASSIGNED", CLIENT_ID_ASSIGNED)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Notice.SessionStateChanged.Parameter") []
        ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "SessionStateChanged"]
        "Parameter")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "SessionStateChanged", "Parameter.hs"]
      [(1, "CURRENT_SCHEMA"), (2, "ACCOUNT_EXPIRED"), (3, "GENERATED_INSERT_ID"), (4, "ROWS_AFFECTED"), (5, "ROWS_FOUND"),
       (6, "ROWS_MATCHED"), (7, "TRX_COMMITTED"), (9, "TRX_ROLLEDBACK"), (10, "PRODUCED_MESSAGE"), (11, "CLIENT_ID_ASSIGNED")]

instance P'.TextType Parameter where
  tellT = P'.tellShow
  getT = P'.getRead