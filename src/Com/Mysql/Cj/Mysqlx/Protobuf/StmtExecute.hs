{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.StmtExecute (StmtExecute(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Any as Com.Mysql.Cj.Mysqlx.Protobuf (Any)

data StmtExecute = StmtExecute{namespace :: !(P'.Maybe P'.Utf8), stmt :: !(P'.ByteString),
                               args :: !(P'.Seq Com.Mysql.Cj.Mysqlx.Protobuf.Any), compact_metadata :: !(P'.Maybe P'.Bool)}
                 deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable StmtExecute where
  mergeAppend (StmtExecute x'1 x'2 x'3 x'4) (StmtExecute y'1 y'2 y'3 y'4)
   = StmtExecute (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2) (P'.mergeAppend x'3 y'3) (P'.mergeAppend x'4 y'4)

instance P'.Default StmtExecute where
  defaultValue
   = StmtExecute (Prelude'.Just (P'.Utf8 (P'.pack "sql"))) P'.defaultValue P'.defaultValue (Prelude'.Just Prelude'.False)

instance P'.Wire StmtExecute where
  wireSize ft' self'@(StmtExecute x'1 x'2 x'3 x'4)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeOpt 1 9 x'1 + P'.wireSizeReq 1 12 x'2 + P'.wireSizeRep 1 11 x'3 + P'.wireSizeOpt 1 8 x'4)
  wirePut ft' self'@(StmtExecute x'1 x'2 x'3 x'4)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutReq 10 12 x'2
             P'.wirePutRep 18 11 x'3
             P'.wirePutOpt 26 9 x'1
             P'.wirePutOpt 32 8 x'4
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             26 -> Prelude'.fmap (\ !new'Field -> old'Self{namespace = Prelude'.Just new'Field}) (P'.wireGet 9)
             10 -> Prelude'.fmap (\ !new'Field -> old'Self{stmt = new'Field}) (P'.wireGet 12)
             18 -> Prelude'.fmap (\ !new'Field -> old'Self{args = P'.append (args old'Self) new'Field}) (P'.wireGet 11)
             32 -> Prelude'.fmap (\ !new'Field -> old'Self{compact_metadata = Prelude'.Just new'Field}) (P'.wireGet 8)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> StmtExecute) StmtExecute where
  getVal m' f' = f' m'

instance P'.GPB StmtExecute

instance P'.ReflectDescriptor StmtExecute where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList [10]) (P'.fromDistinctAscList [10, 18, 26, 32])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Sql.StmtExecute\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"StmtExecute\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"StmtExecute.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Sql.StmtExecute.namespace\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"StmtExecute\"], baseName' = FName \"namespace\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 26}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Just \"sql\", hsDefault = Just (HsDef'ByteString \"sql\")},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Sql.StmtExecute.stmt\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"StmtExecute\"], baseName' = FName \"stmt\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 12}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Sql.StmtExecute.args\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"StmtExecute\"], baseName' = FName \"args\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Datatypes.Any\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Any\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Sql.StmtExecute.compact_metadata\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"StmtExecute\"], baseName' = FName \"compact_metadata\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 4}, wireTag = WireTag {getWireTag = 32}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 8}, typeName = Nothing, hsRawDefault = Just \"false\", hsDefault = Just (HsDef'Bool False)}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType StmtExecute where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg StmtExecute where
  textPut msg
   = do
       P'.tellT "namespace" (namespace msg)
       P'.tellT "stmt" (stmt msg)
       P'.tellT "args" (args msg)
       P'.tellT "compact_metadata" (compact_metadata msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'namespace, parse'stmt, parse'args, parse'compact_metadata]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'namespace
         = P'.try
            (do
               v <- P'.getT "namespace"
               Prelude'.return (\ o -> o{namespace = v}))
        parse'stmt
         = P'.try
            (do
               v <- P'.getT "stmt"
               Prelude'.return (\ o -> o{stmt = v}))
        parse'args
         = P'.try
            (do
               v <- P'.getT "args"
               Prelude'.return (\ o -> o{args = P'.append (args o) v}))
        parse'compact_metadata
         = P'.try
            (do
               v <- P'.getT "compact_metadata"
               Prelude'.return (\ o -> o{compact_metadata = v}))