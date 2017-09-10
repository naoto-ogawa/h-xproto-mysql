{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.ViewAlgorithm (ViewAlgorithm(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data ViewAlgorithm = UNDEFINED
                   | MERGE
                   | TEMPTABLE
                   deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                             Prelude'.Generic)

instance P'.Mergeable ViewAlgorithm

instance Prelude'.Bounded ViewAlgorithm where
  minBound = UNDEFINED
  maxBound = TEMPTABLE

instance P'.Default ViewAlgorithm where
  defaultValue = UNDEFINED

toMaybe'Enum :: Prelude'.Int -> P'.Maybe ViewAlgorithm
toMaybe'Enum 1 = Prelude'.Just UNDEFINED
toMaybe'Enum 2 = Prelude'.Just MERGE
toMaybe'Enum 3 = Prelude'.Just TEMPTABLE
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum ViewAlgorithm where
  fromEnum UNDEFINED = 1
  fromEnum MERGE = 2
  fromEnum TEMPTABLE = 3
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewAlgorithm") .
      toMaybe'Enum
  succ UNDEFINED = MERGE
  succ MERGE = TEMPTABLE
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewAlgorithm"
  pred MERGE = UNDEFINED
  pred TEMPTABLE = MERGE
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.ViewAlgorithm"

instance P'.Wire ViewAlgorithm where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB ViewAlgorithm

instance P'.MessageAPI msg' (msg' -> ViewAlgorithm) ViewAlgorithm where
  getVal m' f' = f' m'

instance P'.ReflectEnum ViewAlgorithm where
  reflectEnum = [(1, "UNDEFINED", UNDEFINED), (2, "MERGE", MERGE), (3, "TEMPTABLE", TEMPTABLE)]
  reflectEnumInfo _
   = P'.EnumInfo (P'.makePNF (P'.pack ".Mysqlx.Crud.ViewAlgorithm") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf"] "ViewAlgorithm")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "ViewAlgorithm.hs"]
      [(1, "UNDEFINED"), (2, "MERGE"), (3, "TEMPTABLE")]

instance P'.TextType ViewAlgorithm where
  tellT = P'.tellShow
  getT = P'.getRead