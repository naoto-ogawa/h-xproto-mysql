{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.ClientMessages.Type (Type(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Type = CON_CAPABILITIES_GET
          | CON_CAPABILITIES_SET
          | CON_CLOSE
          | SESS_AUTHENTICATE_START
          | SESS_AUTHENTICATE_CONTINUE
          | SESS_RESET
          | SESS_CLOSE
          | SQL_STMT_EXECUTE
          | CRUD_FIND
          | CRUD_INSERT
          | CRUD_UPDATE
          | CRUD_DELETE
          | EXPECT_OPEN
          | EXPECT_CLOSE
          | CRUD_CREATE_VIEW
          | CRUD_MODIFY_VIEW
          | CRUD_DROP_VIEW
          deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Type

instance Prelude'.Bounded Type where
  minBound = CON_CAPABILITIES_GET
  maxBound = CRUD_DROP_VIEW

instance P'.Default Type where
  defaultValue = CON_CAPABILITIES_GET

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Type
toMaybe'Enum 1 = Prelude'.Just CON_CAPABILITIES_GET
toMaybe'Enum 2 = Prelude'.Just CON_CAPABILITIES_SET
toMaybe'Enum 3 = Prelude'.Just CON_CLOSE
toMaybe'Enum 4 = Prelude'.Just SESS_AUTHENTICATE_START
toMaybe'Enum 5 = Prelude'.Just SESS_AUTHENTICATE_CONTINUE
toMaybe'Enum 6 = Prelude'.Just SESS_RESET
toMaybe'Enum 7 = Prelude'.Just SESS_CLOSE
toMaybe'Enum 12 = Prelude'.Just SQL_STMT_EXECUTE
toMaybe'Enum 17 = Prelude'.Just CRUD_FIND
toMaybe'Enum 18 = Prelude'.Just CRUD_INSERT
toMaybe'Enum 19 = Prelude'.Just CRUD_UPDATE
toMaybe'Enum 20 = Prelude'.Just CRUD_DELETE
toMaybe'Enum 24 = Prelude'.Just EXPECT_OPEN
toMaybe'Enum 25 = Prelude'.Just EXPECT_CLOSE
toMaybe'Enum 30 = Prelude'.Just CRUD_CREATE_VIEW
toMaybe'Enum 31 = Prelude'.Just CRUD_MODIFY_VIEW
toMaybe'Enum 32 = Prelude'.Just CRUD_DROP_VIEW
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Type where
  fromEnum CON_CAPABILITIES_GET = 1
  fromEnum CON_CAPABILITIES_SET = 2
  fromEnum CON_CLOSE = 3
  fromEnum SESS_AUTHENTICATE_START = 4
  fromEnum SESS_AUTHENTICATE_CONTINUE = 5
  fromEnum SESS_RESET = 6
  fromEnum SESS_CLOSE = 7
  fromEnum SQL_STMT_EXECUTE = 12
  fromEnum CRUD_FIND = 17
  fromEnum CRUD_INSERT = 18
  fromEnum CRUD_UPDATE = 19
  fromEnum CRUD_DELETE = 20
  fromEnum EXPECT_OPEN = 24
  fromEnum EXPECT_CLOSE = 25
  fromEnum CRUD_CREATE_VIEW = 30
  fromEnum CRUD_MODIFY_VIEW = 31
  fromEnum CRUD_DROP_VIEW = 32
  toEnum
   = P'.fromMaybe
      (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ClientMessages.Type")
      . toMaybe'Enum
  succ CON_CAPABILITIES_GET = CON_CAPABILITIES_SET
  succ CON_CAPABILITIES_SET = CON_CLOSE
  succ CON_CLOSE = SESS_AUTHENTICATE_START
  succ SESS_AUTHENTICATE_START = SESS_AUTHENTICATE_CONTINUE
  succ SESS_AUTHENTICATE_CONTINUE = SESS_RESET
  succ SESS_RESET = SESS_CLOSE
  succ SESS_CLOSE = SQL_STMT_EXECUTE
  succ SQL_STMT_EXECUTE = CRUD_FIND
  succ CRUD_FIND = CRUD_INSERT
  succ CRUD_INSERT = CRUD_UPDATE
  succ CRUD_UPDATE = CRUD_DELETE
  succ CRUD_DELETE = EXPECT_OPEN
  succ EXPECT_OPEN = EXPECT_CLOSE
  succ EXPECT_CLOSE = CRUD_CREATE_VIEW
  succ CRUD_CREATE_VIEW = CRUD_MODIFY_VIEW
  succ CRUD_MODIFY_VIEW = CRUD_DROP_VIEW
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ClientMessages.Type"
  pred CON_CAPABILITIES_SET = CON_CAPABILITIES_GET
  pred CON_CLOSE = CON_CAPABILITIES_SET
  pred SESS_AUTHENTICATE_START = CON_CLOSE
  pred SESS_AUTHENTICATE_CONTINUE = SESS_AUTHENTICATE_START
  pred SESS_RESET = SESS_AUTHENTICATE_CONTINUE
  pred SESS_CLOSE = SESS_RESET
  pred SQL_STMT_EXECUTE = SESS_CLOSE
  pred CRUD_FIND = SQL_STMT_EXECUTE
  pred CRUD_INSERT = CRUD_FIND
  pred CRUD_UPDATE = CRUD_INSERT
  pred CRUD_DELETE = CRUD_UPDATE
  pred EXPECT_OPEN = CRUD_DELETE
  pred EXPECT_CLOSE = EXPECT_OPEN
  pred CRUD_CREATE_VIEW = EXPECT_CLOSE
  pred CRUD_MODIFY_VIEW = CRUD_CREATE_VIEW
  pred CRUD_DROP_VIEW = CRUD_MODIFY_VIEW
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ClientMessages.Type"

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
   = [(1, "CON_CAPABILITIES_GET", CON_CAPABILITIES_GET), (2, "CON_CAPABILITIES_SET", CON_CAPABILITIES_SET),
      (3, "CON_CLOSE", CON_CLOSE), (4, "SESS_AUTHENTICATE_START", SESS_AUTHENTICATE_START),
      (5, "SESS_AUTHENTICATE_CONTINUE", SESS_AUTHENTICATE_CONTINUE), (6, "SESS_RESET", SESS_RESET), (7, "SESS_CLOSE", SESS_CLOSE),
      (12, "SQL_STMT_EXECUTE", SQL_STMT_EXECUTE), (17, "CRUD_FIND", CRUD_FIND), (18, "CRUD_INSERT", CRUD_INSERT),
      (19, "CRUD_UPDATE", CRUD_UPDATE), (20, "CRUD_DELETE", CRUD_DELETE), (24, "EXPECT_OPEN", EXPECT_OPEN),
      (25, "EXPECT_CLOSE", EXPECT_CLOSE), (30, "CRUD_CREATE_VIEW", CRUD_CREATE_VIEW), (31, "CRUD_MODIFY_VIEW", CRUD_MODIFY_VIEW),
      (32, "CRUD_DROP_VIEW", CRUD_DROP_VIEW)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.ClientMessages.Type") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ClientMessages"] "Type")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ClientMessages", "Type.hs"]
      [(1, "CON_CAPABILITIES_GET"), (2, "CON_CAPABILITIES_SET"), (3, "CON_CLOSE"), (4, "SESS_AUTHENTICATE_START"),
       (5, "SESS_AUTHENTICATE_CONTINUE"), (6, "SESS_RESET"), (7, "SESS_CLOSE"), (12, "SQL_STMT_EXECUTE"), (17, "CRUD_FIND"),
       (18, "CRUD_INSERT"), (19, "CRUD_UPDATE"), (20, "CRUD_DELETE"), (24, "EXPECT_OPEN"), (25, "EXPECT_CLOSE"),
       (30, "CRUD_CREATE_VIEW"), (31, "CRUD_MODIFY_VIEW"), (32, "CRUD_DROP_VIEW")]

instance P'.TextType Type where
  tellT = P'.tellShow
  getT = P'.getRead