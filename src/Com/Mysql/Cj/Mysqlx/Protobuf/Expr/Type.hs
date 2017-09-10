{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Expr.Type (Type(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Type = IDENT
          | LITERAL
          | VARIABLE
          | FUNC_CALL
          | OPERATOR
          | PLACEHOLDER
          | OBJECT
          | ARRAY
          deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Type

instance Prelude'.Bounded Type where
  minBound = IDENT
  maxBound = ARRAY

instance P'.Default Type where
  defaultValue = IDENT

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Type
toMaybe'Enum 1 = Prelude'.Just IDENT
toMaybe'Enum 2 = Prelude'.Just LITERAL
toMaybe'Enum 3 = Prelude'.Just VARIABLE
toMaybe'Enum 4 = Prelude'.Just FUNC_CALL
toMaybe'Enum 5 = Prelude'.Just OPERATOR
toMaybe'Enum 6 = Prelude'.Just PLACEHOLDER
toMaybe'Enum 7 = Prelude'.Just OBJECT
toMaybe'Enum 8 = Prelude'.Just ARRAY
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Type where
  fromEnum IDENT = 1
  fromEnum LITERAL = 2
  fromEnum VARIABLE = 3
  fromEnum FUNC_CALL = 4
  fromEnum OPERATOR = 5
  fromEnum PLACEHOLDER = 6
  fromEnum OBJECT = 7
  fromEnum ARRAY = 8
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Expr.Type") .
      toMaybe'Enum
  succ IDENT = LITERAL
  succ LITERAL = VARIABLE
  succ VARIABLE = FUNC_CALL
  succ FUNC_CALL = OPERATOR
  succ OPERATOR = PLACEHOLDER
  succ PLACEHOLDER = OBJECT
  succ OBJECT = ARRAY
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Expr.Type"
  pred LITERAL = IDENT
  pred VARIABLE = LITERAL
  pred FUNC_CALL = VARIABLE
  pred OPERATOR = FUNC_CALL
  pred PLACEHOLDER = OPERATOR
  pred OBJECT = PLACEHOLDER
  pred ARRAY = OBJECT
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Expr.Type"

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
   = [(1, "IDENT", IDENT), (2, "LITERAL", LITERAL), (3, "VARIABLE", VARIABLE), (4, "FUNC_CALL", FUNC_CALL),
      (5, "OPERATOR", OPERATOR), (6, "PLACEHOLDER", PLACEHOLDER), (7, "OBJECT", OBJECT), (8, "ARRAY", ARRAY)]
  reflectEnumInfo _
   = P'.EnumInfo (P'.makePNF (P'.pack ".Mysqlx.Expr.Expr.Type") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Expr"] "Type")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Expr", "Type.hs"]
      [(1, "IDENT"), (2, "LITERAL"), (3, "VARIABLE"), (4, "FUNC_CALL"), (5, "OPERATOR"), (6, "PLACEHOLDER"), (7, "OBJECT"),
       (8, "ARRAY")]

instance P'.TextType Type where
  tellT = P'.tellShow
  getT = P'.getRead