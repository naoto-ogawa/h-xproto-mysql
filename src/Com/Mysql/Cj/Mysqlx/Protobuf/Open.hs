{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Open (Open(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition as Com.Mysql.Cj.Mysqlx.Protobuf.Open (Condition)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Open.CtxOperation as Com.Mysql.Cj.Mysqlx.Protobuf.Open (CtxOperation)

data Open = Open{op :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Open.CtxOperation),
                 cond :: !(P'.Seq Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition)}
          deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Open where
  mergeAppend (Open x'1 x'2) (Open y'1 y'2) = Open (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2)

instance P'.Default Open where
  defaultValue = Open (Prelude'.Just (Prelude'.read "EXPECT_CTX_COPY_PREV")) P'.defaultValue

instance P'.Wire Open where
  wireSize ft' self'@(Open x'1 x'2)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeOpt 1 14 x'1 + P'.wireSizeRep 1 11 x'2)
  wirePut ft' self'@(Open x'1 x'2)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutOpt 8 14 x'1
             P'.wirePutRep 18 11 x'2
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             8 -> Prelude'.fmap (\ !new'Field -> old'Self{op = Prelude'.Just new'Field}) (P'.wireGet 14)
             18 -> Prelude'.fmap (\ !new'Field -> old'Self{cond = P'.append (cond old'Self) new'Field}) (P'.wireGet 11)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> Open) Open where
  getVal m' f' = f' m'

instance P'.GPB Open

instance P'.ReflectDescriptor Open where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [8, 18])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Expect.Open\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Open\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"Open.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expect.Open.op\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\"], baseName' = FName \"op\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expect.Open.CtxOperation\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\"], baseName = MName \"CtxOperation\"}), hsRawDefault = Just \"EXPECT_CTX_COPY_PREV\", hsDefault = Just (HsDef'Enum \"EXPECT_CTX_COPY_PREV\")},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expect.Open.cond\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\"], baseName' = FName \"cond\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expect.Open.Condition\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Open\"], baseName = MName \"Condition\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType Open where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg Open where
  textPut msg
   = do
       P'.tellT "op" (op msg)
       P'.tellT "cond" (cond msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'op, parse'cond]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'op
         = P'.try
            (do
               v <- P'.getT "op"
               Prelude'.return (\ o -> o{op = v}))
        parse'cond
         = P'.try
            (do
               v <- P'.getT "cond"
               Prelude'.return (\ o -> o{cond = P'.append (cond o) v}))