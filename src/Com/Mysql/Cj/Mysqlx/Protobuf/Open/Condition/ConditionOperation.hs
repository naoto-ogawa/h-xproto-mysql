{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition.ConditionOperation (ConditionOperation(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data ConditionOperation = EXPECT_OP_SET
                        | EXPECT_OP_UNSET
                        deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                                  Prelude'.Generic)

instance P'.Mergeable ConditionOperation

instance Prelude'.Bounded ConditionOperation where
  minBound = EXPECT_OP_SET
  maxBound = EXPECT_OP_UNSET

instance P'.Default ConditionOperation where
  defaultValue = EXPECT_OP_SET

toMaybe'Enum :: Prelude'.Int -> P'.Maybe ConditionOperation
toMaybe'Enum 0 = Prelude'.Just EXPECT_OP_SET
toMaybe'Enum 1 = Prelude'.Just EXPECT_OP_UNSET
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum ConditionOperation where
  fromEnum EXPECT_OP_SET = 0
  fromEnum EXPECT_OP_UNSET = 1
  toEnum
   = P'.fromMaybe
      (Prelude'.error
        "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition.ConditionOperation")
      . toMaybe'Enum
  succ EXPECT_OP_SET = EXPECT_OP_UNSET
  succ _
   = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition.ConditionOperation"
  pred EXPECT_OP_UNSET = EXPECT_OP_SET
  pred _
   = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition.ConditionOperation"

instance P'.Wire ConditionOperation where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB ConditionOperation

instance P'.MessageAPI msg' (msg' -> ConditionOperation) ConditionOperation where
  getVal m' f' = f' m'

instance P'.ReflectEnum ConditionOperation where
  reflectEnum = [(0, "EXPECT_OP_SET", EXPECT_OP_SET), (1, "EXPECT_OP_UNSET", EXPECT_OP_UNSET)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Expect.Open.Condition.ConditionOperation") []
        ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Open", "Condition"]
        "ConditionOperation")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Open", "Condition", "ConditionOperation.hs"]
      [(0, "EXPECT_OP_SET"), (1, "EXPECT_OP_UNSET")]

instance P'.TextType ConditionOperation where
  tellT = P'.tellShow
  getT = P'.getRead