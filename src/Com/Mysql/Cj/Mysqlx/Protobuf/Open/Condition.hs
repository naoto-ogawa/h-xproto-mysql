{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition (Condition(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition.ConditionOperation as Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition
       (ConditionOperation)

data Condition = Condition{condition_key :: !(P'.Word32), condition_value :: !(P'.Maybe P'.ByteString),
                           op :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition.ConditionOperation)}
               deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Condition where
  mergeAppend (Condition x'1 x'2 x'3) (Condition y'1 y'2 y'3)
   = Condition (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2) (P'.mergeAppend x'3 y'3)

instance P'.Default Condition where
  defaultValue = Condition P'.defaultValue P'.defaultValue (Prelude'.Just (Prelude'.read "EXPECT_OP_SET"))

instance P'.Wire Condition where
  wireSize ft' self'@(Condition x'1 x'2 x'3)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeReq 1 13 x'1 + P'.wireSizeOpt 1 12 x'2 + P'.wireSizeOpt 1 14 x'3)
  wirePut ft' self'@(Condition x'1 x'2 x'3)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutReq 8 13 x'1
             P'.wirePutOpt 18 12 x'2
             P'.wirePutOpt 24 14 x'3
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             8 -> Prelude'.fmap (\ !new'Field -> old'Self{condition_key = new'Field}) (P'.wireGet 13)
             18 -> Prelude'.fmap (\ !new'Field -> old'Self{condition_value = Prelude'.Just new'Field}) (P'.wireGet 12)
             24 -> Prelude'.fmap (\ !new'Field -> old'Self{op = Prelude'.Just new'Field}) (P'.wireGet 14)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> Condition) Condition where
  getVal m' f' = f' m'

instance P'.GPB Condition

instance P'.ReflectDescriptor Condition where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList [8]) (P'.fromDistinctAscList [8, 18, 24])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Expect.Open.Condition\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\"], baseName = MName \"Condition\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"Open\",\"Condition.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expect.Open.Condition.condition_key\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\",MName \"Condition\"], baseName' = FName \"condition_key\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 13}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expect.Open.Condition.condition_value\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\",MName \"Condition\"], baseName' = FName \"condition_value\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 12}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expect.Open.Condition.op\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\",MName \"Condition\"], baseName' = FName \"op\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 24}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expect.Open.Condition.ConditionOperation\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\",MName \"Condition\"], baseName = MName \"ConditionOperation\"}), hsRawDefault = Just \"EXPECT_OP_SET\", hsDefault = Just (HsDef'Enum \"EXPECT_OP_SET\")}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType Condition where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg Condition where
  textPut msg
   = do
       P'.tellT "condition_key" (condition_key msg)
       P'.tellT "condition_value" (condition_value msg)
       P'.tellT "op" (op msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'condition_key, parse'condition_value, parse'op]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'condition_key
         = P'.try
            (do
               v <- P'.getT "condition_key"
               Prelude'.return (\ o -> o{condition_key = v}))
        parse'condition_value
         = P'.try
            (do
               v <- P'.getT "condition_value"
               Prelude'.return (\ o -> o{condition_value = v}))
        parse'op
         = P'.try
            (do
               v <- P'.getT "op"
               Prelude'.return (\ o -> o{op = v}))