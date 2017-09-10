{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.ServerMessages.Type (Type(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Type = OK
          | ERROR
          | CONN_CAPABILITIES
          | SESS_AUTHENTICATE_CONTINUE
          | SESS_AUTHENTICATE_OK
          | NOTICE
          | RESULTSET_COLUMN_META_DATA
          | RESULTSET_ROW
          | RESULTSET_FETCH_DONE
          | RESULTSET_FETCH_SUSPENDED
          | RESULTSET_FETCH_DONE_MORE_RESULTSETS
          | SQL_STMT_EXECUTE_OK
          | RESULTSET_FETCH_DONE_MORE_OUT_PARAMS
          deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Type

instance Prelude'.Bounded Type where
  minBound = OK
  maxBound = RESULTSET_FETCH_DONE_MORE_OUT_PARAMS

instance P'.Default Type where
  defaultValue = OK

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Type
toMaybe'Enum 0 = Prelude'.Just OK
toMaybe'Enum 1 = Prelude'.Just ERROR
toMaybe'Enum 2 = Prelude'.Just CONN_CAPABILITIES
toMaybe'Enum 3 = Prelude'.Just SESS_AUTHENTICATE_CONTINUE
toMaybe'Enum 4 = Prelude'.Just SESS_AUTHENTICATE_OK
toMaybe'Enum 11 = Prelude'.Just NOTICE
toMaybe'Enum 12 = Prelude'.Just RESULTSET_COLUMN_META_DATA
toMaybe'Enum 13 = Prelude'.Just RESULTSET_ROW
toMaybe'Enum 14 = Prelude'.Just RESULTSET_FETCH_DONE
toMaybe'Enum 15 = Prelude'.Just RESULTSET_FETCH_SUSPENDED
toMaybe'Enum 16 = Prelude'.Just RESULTSET_FETCH_DONE_MORE_RESULTSETS
toMaybe'Enum 17 = Prelude'.Just SQL_STMT_EXECUTE_OK
toMaybe'Enum 18 = Prelude'.Just RESULTSET_FETCH_DONE_MORE_OUT_PARAMS
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Type where
  fromEnum OK = 0
  fromEnum ERROR = 1
  fromEnum CONN_CAPABILITIES = 2
  fromEnum SESS_AUTHENTICATE_CONTINUE = 3
  fromEnum SESS_AUTHENTICATE_OK = 4
  fromEnum NOTICE = 11
  fromEnum RESULTSET_COLUMN_META_DATA = 12
  fromEnum RESULTSET_ROW = 13
  fromEnum RESULTSET_FETCH_DONE = 14
  fromEnum RESULTSET_FETCH_SUSPENDED = 15
  fromEnum RESULTSET_FETCH_DONE_MORE_RESULTSETS = 16
  fromEnum SQL_STMT_EXECUTE_OK = 17
  fromEnum RESULTSET_FETCH_DONE_MORE_OUT_PARAMS = 18
  toEnum
   = P'.fromMaybe
      (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ServerMessages.Type")
      . toMaybe'Enum
  succ OK = ERROR
  succ ERROR = CONN_CAPABILITIES
  succ CONN_CAPABILITIES = SESS_AUTHENTICATE_CONTINUE
  succ SESS_AUTHENTICATE_CONTINUE = SESS_AUTHENTICATE_OK
  succ SESS_AUTHENTICATE_OK = NOTICE
  succ NOTICE = RESULTSET_COLUMN_META_DATA
  succ RESULTSET_COLUMN_META_DATA = RESULTSET_ROW
  succ RESULTSET_ROW = RESULTSET_FETCH_DONE
  succ RESULTSET_FETCH_DONE = RESULTSET_FETCH_SUSPENDED
  succ RESULTSET_FETCH_SUSPENDED = RESULTSET_FETCH_DONE_MORE_RESULTSETS
  succ RESULTSET_FETCH_DONE_MORE_RESULTSETS = SQL_STMT_EXECUTE_OK
  succ SQL_STMT_EXECUTE_OK = RESULTSET_FETCH_DONE_MORE_OUT_PARAMS
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ServerMessages.Type"
  pred ERROR = OK
  pred CONN_CAPABILITIES = ERROR
  pred SESS_AUTHENTICATE_CONTINUE = CONN_CAPABILITIES
  pred SESS_AUTHENTICATE_OK = SESS_AUTHENTICATE_CONTINUE
  pred NOTICE = SESS_AUTHENTICATE_OK
  pred RESULTSET_COLUMN_META_DATA = NOTICE
  pred RESULTSET_ROW = RESULTSET_COLUMN_META_DATA
  pred RESULTSET_FETCH_DONE = RESULTSET_ROW
  pred RESULTSET_FETCH_SUSPENDED = RESULTSET_FETCH_DONE
  pred RESULTSET_FETCH_DONE_MORE_RESULTSETS = RESULTSET_FETCH_SUSPENDED
  pred SQL_STMT_EXECUTE_OK = RESULTSET_FETCH_DONE_MORE_RESULTSETS
  pred RESULTSET_FETCH_DONE_MORE_OUT_PARAMS = SQL_STMT_EXECUTE_OK
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ServerMessages.Type"

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
   = [(0, "OK", OK), (1, "ERROR", ERROR), (2, "CONN_CAPABILITIES", CONN_CAPABILITIES),
      (3, "SESS_AUTHENTICATE_CONTINUE", SESS_AUTHENTICATE_CONTINUE), (4, "SESS_AUTHENTICATE_OK", SESS_AUTHENTICATE_OK),
      (11, "NOTICE", NOTICE), (12, "RESULTSET_COLUMN_META_DATA", RESULTSET_COLUMN_META_DATA), (13, "RESULTSET_ROW", RESULTSET_ROW),
      (14, "RESULTSET_FETCH_DONE", RESULTSET_FETCH_DONE), (15, "RESULTSET_FETCH_SUSPENDED", RESULTSET_FETCH_SUSPENDED),
      (16, "RESULTSET_FETCH_DONE_MORE_RESULTSETS", RESULTSET_FETCH_DONE_MORE_RESULTSETS),
      (17, "SQL_STMT_EXECUTE_OK", SQL_STMT_EXECUTE_OK),
      (18, "RESULTSET_FETCH_DONE_MORE_OUT_PARAMS", RESULTSET_FETCH_DONE_MORE_OUT_PARAMS)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.ServerMessages.Type") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ServerMessages"] "Type")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ServerMessages", "Type.hs"]
      [(0, "OK"), (1, "ERROR"), (2, "CONN_CAPABILITIES"), (3, "SESS_AUTHENTICATE_CONTINUE"), (4, "SESS_AUTHENTICATE_OK"),
       (11, "NOTICE"), (12, "RESULTSET_COLUMN_META_DATA"), (13, "RESULTSET_ROW"), (14, "RESULTSET_FETCH_DONE"),
       (15, "RESULTSET_FETCH_SUSPENDED"), (16, "RESULTSET_FETCH_DONE_MORE_RESULTSETS"), (17, "SQL_STMT_EXECUTE_OK"),
       (18, "RESULTSET_FETCH_DONE_MORE_OUT_PARAMS")]

instance P'.TextType Type where
  tellT = P'.tellShow
  getT = P'.getRead