{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.ModifyView (ModifyView(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Collection as Com.Mysql.Cj.Mysqlx.Protobuf (Collection)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find as Com.Mysql.Cj.Mysqlx.Protobuf (Find)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ViewAlgorithm as Com.Mysql.Cj.Mysqlx.Protobuf (ViewAlgorithm)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ViewCheckOption as Com.Mysql.Cj.Mysqlx.Protobuf (ViewCheckOption)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ViewSqlSecurity as Com.Mysql.Cj.Mysqlx.Protobuf (ViewSqlSecurity)

data ModifyView = ModifyView{collection :: !(Com.Mysql.Cj.Mysqlx.Protobuf.Collection), definer :: !(P'.Maybe P'.Utf8),
                             algorithm :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ViewAlgorithm),
                             security :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ViewSqlSecurity),
                             check :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ViewCheckOption), column :: !(P'.Seq P'.Utf8),
                             stmt :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Find)}
                deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable ModifyView where
  mergeAppend (ModifyView x'1 x'2 x'3 x'4 x'5 x'6 x'7) (ModifyView y'1 y'2 y'3 y'4 y'5 y'6 y'7)
   = ModifyView (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2) (P'.mergeAppend x'3 y'3) (P'.mergeAppend x'4 y'4)
      (P'.mergeAppend x'5 y'5)
      (P'.mergeAppend x'6 y'6)
      (P'.mergeAppend x'7 y'7)

instance P'.Default ModifyView where
  defaultValue
   = ModifyView P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue

instance P'.Wire ModifyView where
  wireSize ft' self'@(ModifyView x'1 x'2 x'3 x'4 x'5 x'6 x'7)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size
         = (P'.wireSizeReq 1 11 x'1 + P'.wireSizeOpt 1 9 x'2 + P'.wireSizeOpt 1 14 x'3 + P'.wireSizeOpt 1 14 x'4 +
             P'.wireSizeOpt 1 14 x'5
             + P'.wireSizeRep 1 9 x'6
             + P'.wireSizeOpt 1 11 x'7)
  wirePut ft' self'@(ModifyView x'1 x'2 x'3 x'4 x'5 x'6 x'7)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutReq 10 11 x'1
             P'.wirePutOpt 18 9 x'2
             P'.wirePutOpt 24 14 x'3
             P'.wirePutOpt 32 14 x'4
             P'.wirePutOpt 40 14 x'5
             P'.wirePutRep 50 9 x'6
             P'.wirePutOpt 58 11 x'7
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             10 -> Prelude'.fmap (\ !new'Field -> old'Self{collection = P'.mergeAppend (collection old'Self) (new'Field)})
                    (P'.wireGet 11)
             18 -> Prelude'.fmap (\ !new'Field -> old'Self{definer = Prelude'.Just new'Field}) (P'.wireGet 9)
             24 -> Prelude'.fmap (\ !new'Field -> old'Self{algorithm = Prelude'.Just new'Field}) (P'.wireGet 14)
             32 -> Prelude'.fmap (\ !new'Field -> old'Self{security = Prelude'.Just new'Field}) (P'.wireGet 14)
             40 -> Prelude'.fmap (\ !new'Field -> old'Self{check = Prelude'.Just new'Field}) (P'.wireGet 14)
             50 -> Prelude'.fmap (\ !new'Field -> old'Self{column = P'.append (column old'Self) new'Field}) (P'.wireGet 9)
             58 -> Prelude'.fmap (\ !new'Field -> old'Self{stmt = P'.mergeAppend (stmt old'Self) (Prelude'.Just new'Field)})
                    (P'.wireGet 11)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> ModifyView) ModifyView where
  getVal m' f' = f' m'

instance P'.GPB ModifyView

instance P'.ReflectDescriptor ModifyView where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList [10]) (P'.fromDistinctAscList [10, 18, 24, 32, 40, 50, 58])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Crud.ModifyView\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ModifyView\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"ModifyView.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.ModifyView.collection\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ModifyView\"], baseName' = FName \"collection\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.Collection\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Collection\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.ModifyView.definer\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ModifyView\"], baseName' = FName \"definer\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.ModifyView.algorithm\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ModifyView\"], baseName' = FName \"algorithm\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 24}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.ViewAlgorithm\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ViewAlgorithm\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.ModifyView.security\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ModifyView\"], baseName' = FName \"security\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 4}, wireTag = WireTag {getWireTag = 32}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.ViewSqlSecurity\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ViewSqlSecurity\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.ModifyView.check\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ModifyView\"], baseName' = FName \"check\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 5}, wireTag = WireTag {getWireTag = 40}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.ViewCheckOption\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ViewCheckOption\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.ModifyView.column\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ModifyView\"], baseName' = FName \"column\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 6}, wireTag = WireTag {getWireTag = 50}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.ModifyView.stmt\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ModifyView\"], baseName' = FName \"stmt\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 7}, wireTag = WireTag {getWireTag = 58}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.Find\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Find\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType ModifyView where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg ModifyView where
  textPut msg
   = do
       P'.tellT "collection" (collection msg)
       P'.tellT "definer" (definer msg)
       P'.tellT "algorithm" (algorithm msg)
       P'.tellT "security" (security msg)
       P'.tellT "check" (check msg)
       P'.tellT "column" (column msg)
       P'.tellT "stmt" (stmt msg)
  textGet
   = do
       mods <- P'.sepEndBy
                (P'.choice
                  [parse'collection, parse'definer, parse'algorithm, parse'security, parse'check, parse'column, parse'stmt])
                P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'collection
         = P'.try
            (do
               v <- P'.getT "collection"
               Prelude'.return (\ o -> o{collection = v}))
        parse'definer
         = P'.try
            (do
               v <- P'.getT "definer"
               Prelude'.return (\ o -> o{definer = v}))
        parse'algorithm
         = P'.try
            (do
               v <- P'.getT "algorithm"
               Prelude'.return (\ o -> o{algorithm = v}))
        parse'security
         = P'.try
            (do
               v <- P'.getT "security"
               Prelude'.return (\ o -> o{security = v}))
        parse'check
         = P'.try
            (do
               v <- P'.getT "check"
               Prelude'.return (\ o -> o{check = v}))
        parse'column
         = P'.try
            (do
               v <- P'.getT "column"
               Prelude'.return (\ o -> o{column = P'.append (column o) v}))
        parse'stmt
         = P'.try
            (do
               v <- P'.getT "stmt"
               Prelude'.return (\ o -> o{stmt = v}))