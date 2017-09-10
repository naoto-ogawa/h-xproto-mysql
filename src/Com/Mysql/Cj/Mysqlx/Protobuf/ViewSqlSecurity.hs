{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.ViewSqlSecurity (ViewSqlSecurity(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data ViewSqlSecurity = INVOKER
                     | DEFINER
                     deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                               Prelude'.Generic)

instance P'.Mergeable ViewSqlSecurity

instance Prelude'.Bounded ViewSqlSecurity where
  minBound = INVOKER
  maxBound = DEFINER

instance P'.Default ViewSqlSecurity where
  defaultValue = INVOKER

toMaybe'Enum :: Prelude'.Int -> P'.Maybe ViewSqlSecurity
toMaybe'Enum 1 = Prelude'.Just INVOKER
toMaybe'Enum 2 = Prelude'.Just DEFINER
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum ViewSqlSecurity where
  fromEnum INVOKER = 1
  fromEnum DEFINER = 2
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewSqlSecurity") .
      toMaybe'Enum
  succ INVOKER = DEFINER
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewSqlSecurity"
  pred DEFINER = INVOKER
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewSqlSecurity"

instance P'.Wire ViewSqlSecurity where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB ViewSqlSecurity

instance P'.MessageAPI msg' (msg' -> ViewSqlSecurity) ViewSqlSecurity where
  getVal m' f' = f' m'

instance P'.ReflectEnum ViewSqlSecurity where
  reflectEnum = [(1, "INVOKER", INVOKER), (2, "DEFINER", DEFINER)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Crud.ViewSqlSecurity") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf"] "ViewSqlSecurity")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ViewSqlSecurity.hs"]
      [(1, "INVOKER"), (2, "DEFINER")]

instance P'.TextType ViewSqlSecurity where
  tellT = P'.tellShow
  getT = P'.getRead