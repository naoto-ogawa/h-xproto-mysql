{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Order.Direction (Direction(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Direction = ASC
               | DESC
               deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                         Prelude'.Generic)

instance P'.Mergeable Direction

instance Prelude'.Bounded Direction where
  minBound = ASC
  maxBound = DESC

instance P'.Default Direction where
  defaultValue = ASC

toMaybe'Enum :: Prelude'.Int -> P'.Maybe Direction
toMaybe'Enum 1 = Prelude'.Just ASC
toMaybe'Enum 2 = Prelude'.Just DESC
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum Direction where
  fromEnum ASC = 1
  fromEnum DESC = 2
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Order.Direction") .
      toMaybe'Enum
  succ ASC = DESC
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Order.Direction"
  pred DESC = ASC
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Order.Direction"

instance P'.Wire Direction where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB Direction

instance P'.MessageAPI msg' (msg' -> Direction) Direction where
  getVal m' f' = f' m'

instance P'.ReflectEnum Direction where
  reflectEnum = [(1, "ASC", ASC), (2, "DESC", DESC)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Crud.Order.Direction") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Order"] "Direction")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Order", "Direction.hs"]
      [(1, "ASC"), (2, "DESC")]

instance P'.TextType Direction where
  tellT = P'.tellShow
  getT = P'.getRead