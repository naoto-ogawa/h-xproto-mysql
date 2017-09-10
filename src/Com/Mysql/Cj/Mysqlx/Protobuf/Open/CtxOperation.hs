{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Open.CtxOperation (CtxOperation(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data CtxOperation = EXPECT_CTX_COPY_PREV
                  | EXPECT_CTX_EMPTY
                  deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data,
                            Prelude'.Generic)

instance P'.Mergeable CtxOperation

instance Prelude'.Bounded CtxOperation where
  minBound = EXPECT_CTX_COPY_PREV
  maxBound = EXPECT_CTX_EMPTY

instance P'.Default CtxOperation where
  defaultValue = EXPECT_CTX_COPY_PREV

toMaybe'Enum :: Prelude'.Int -> P'.Maybe CtxOperation
toMaybe'Enum 0 = Prelude'.Just EXPECT_CTX_COPY_PREV
toMaybe'Enum 1 = Prelude'.Just EXPECT_CTX_EMPTY
toMaybe'Enum _ = Prelude'.Nothing

instance Prelude'.Enum CtxOperation where
  fromEnum EXPECT_CTX_COPY_PREV = 0
  fromEnum EXPECT_CTX_EMPTY = 1
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Open.CtxOperation")
      . toMaybe'Enum
  succ EXPECT_CTX_COPY_PREV = EXPECT_CTX_EMPTY
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Open.CtxOperation"
  pred EXPECT_CTX_EMPTY = EXPECT_CTX_COPY_PREV
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Com.Mysql.Cj.Mysqlx.Protobuf.Open.CtxOperation"

instance P'.Wire CtxOperation where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'

instance P'.GPB CtxOperation

instance P'.MessageAPI msg' (msg' -> CtxOperation) CtxOperation where
  getVal m' f' = f' m'

instance P'.ReflectEnum CtxOperation where
  reflectEnum = [(0, "EXPECT_CTX_COPY_PREV", EXPECT_CTX_COPY_PREV), (1, "EXPECT_CTX_EMPTY", EXPECT_CTX_EMPTY)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Mysqlx.Expect.Open.CtxOperation") [] ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Open"]
        "CtxOperation")
      ["Com", "Mysql", "Cj", "Mysqlx", "Protobuf", "Open", "CtxOperation.hs"]
      [(0, "EXPECT_CTX_COPY_PREV"), (1, "EXPECT_CTX_EMPTY")]

instance P'.TextType CtxOperation where
  tellT = P'.tellShow
  getT = P'.getRead