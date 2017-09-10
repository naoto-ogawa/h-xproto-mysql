{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.ViewCheckOption (ViewCheckOption(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data ViewCheckOption = LOCAL
                     | CASCADED
                     deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                               Prelude'.Generic)

instance P'.Mergeable ViewCheckOption

instance Prelude'.Bounded ViewCheckOption where
  minBound = LOCAL
  maxBound = CASCADED

instance P'.Default ViewCheckOption where
  defaultValue = LOCAL

toMaybe'Enum :: Prelude'.Int -> P'.Maybe ViewCheckOption
toMaybe'Enum 1 = Prelude'.Just LOCAL
toMaybe'Enum 2 = Prelude'.Just CASCADED
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum ViewCheckOption where
  fromEnum LOCAL = 1
  fromEnum CASCADED = 2
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewCheckOption") .
      toMaybe'Enum
  succ LOCAL = CASCADED
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewCheckOption"
  pred CASCADED = LOCAL
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewCheckOption"

instance P'.Wire ViewCheckOption where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB ViewCheckOption

instance P'.MessageAPI msg' (msg' -> ViewCheckOption) ViewCheckOption where
  getVal m' f' = f' m'

instance P'.ReflectEnum ViewCheckOption where
  reflectEnum = [(1, "LOCAL", LOCAL), (2, "CASCADED", CASCADED)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Crud.ViewCheckOption") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf"] "ViewCheckOption")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ViewCheckOption.hs"]
      [(1, "LOCAL"), (2, "CASCADED")]

instance P'.TextType ViewCheckOption where
  tellT = P'.tellShow
  getT = P'.getRead