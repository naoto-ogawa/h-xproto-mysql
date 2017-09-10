{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.CreateView (CreateView(..)) where
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

data CreateView = CreateView{collection :: !(Com.Mysql.Cj.Mysqlx.Protobuf.Collection), definer :: !(P'.Maybe P'.Utf8),
                             algorithm :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ViewAlgorithm),
                             security :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ViewSqlSecurity),
                             check :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ViewCheckOption), column :: !(P'.Seq P'.Utf8),
                             stmt :: !(Com.Mysql.Cj.Mysqlx.Protobuf.Find), replace_existing :: !(P'.Maybe P'.Bool)}
                deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable CreateView where
  mergeAppend (CreateView x'1 x'2 x'3 x'4 x'5 x'6 x'7 x'8) (CreateView y'1 y'2 y'3 y'4 y'5 y'6 y'7 y'8)
   = CreateView (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2) (P'.mergeAppend x'3 y'3) (P'.mergeAppend x'4 y'4)
      (P'.mergeAppend x'5 y'5)
      (P'.mergeAppend x'6 y'6)
      (P'.mergeAppend x'7 y'7)
      (P'.mergeAppend x'8 y'8)

instance P'.Default CreateView where
  defaultValue
   = CreateView P'.defaultValue P'.defaultValue (Prelude'.Just (Prelude'.read "UNDEFINED"))
      (Prelude'.Just (Prelude'.read "DEFINER"))
      P'.defaultValue
      P'.defaultValue
      P'.defaultValue
      (Prelude'.Just Prelude'.False)

instance P'.Wire CreateView where
  wireSize ft' self'@(CreateView x'1 x'2 x'3 x'4 x'5 x'6 x'7 x'8)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size
         = (P'.wireSizeReq 1 11 x'1 + P'.wireSizeOpt 1 9 x'2 + P'.wireSizeOpt 1 14 x'3 + P'.wireSizeOpt 1 14 x'4 +
             P'.wireSizeOpt 1 14 x'5
             + P'.wireSizeRep 1 9 x'6
             + P'.wireSizeReq 1 11 x'7
             + P'.wireSizeOpt 1 8 x'8)
  wirePut ft' self'@(CreateView x'1 x'2 x'3 x'4 x'5 x'6 x'7 x'8)
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
             P'.wirePutReq 58 11 x'7
             P'.wirePutOpt 64 8 x'8
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
             58 -> Prelude'.fmap (\ !new'Field -> old'Self{stmt = P'.mergeAppend (stmt old'Self) (new'Field)}) (P'.wireGet 11)
             64 -> Prelude'.fmap (\ !new'Field -> old'Self{replace_existing = Prelude'.Just new'Field}) (P'.wireGet 8)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> CreateView) CreateView where
  getVal m' f' = f' m'

instance P'.GPB CreateView

instance P'.ReflectDescriptor CreateView where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList [10, 58]) (P'.fromDistinctAscList [10, 18, 24, 32, 40, 50, 58, 64])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Crud.CreateView\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"CreateView\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"CreateView.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.CreateView.collection\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"CreateView\"], baseName' = FName \"collection\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.Collection\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Collection\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.CreateView.definer\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"CreateView\"], baseName' = FName \"definer\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.CreateView.algorithm\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"CreateView\"], baseName' = FName \"algorithm\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 24}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.ViewAlgorithm\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ViewAlgorithm\"}), hsRawDefault = Just \"UNDEFINED\", hsDefault = Just (HsDef'Enum \"UNDEFINED\")},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.CreateView.security\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"CreateView\"], baseName' = FName \"security\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 4}, wireTag = WireTag {getWireTag = 32}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.ViewSqlSecurity\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ViewSqlSecurity\"}), hsRawDefault = Just \"DEFINER\", hsDefault = Just (HsDef'Enum \"DEFINER\")},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.CreateView.check\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"CreateView\"], baseName' = FName \"check\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 5}, wireTag = WireTag {getWireTag = 40}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.ViewCheckOption\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ViewCheckOption\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.CreateView.column\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"CreateView\"], baseName' = FName \"column\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 6}, wireTag = WireTag {getWireTag = 50}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.CreateView.stmt\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"CreateView\"], baseName' = FName \"stmt\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 7}, wireTag = WireTag {getWireTag = 58}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Crud.Find\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Find\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Crud.CreateView.replace_existing\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"CreateView\"], baseName' = FName \"replace_existing\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 8}, wireTag = WireTag {getWireTag = 64}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 8}, typeName = Nothing, hsRawDefault = Just \"false\", hsDefault = Just (HsDef'Bool False)}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType CreateView where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg CreateView where
  textPut msg
   = do
       P'.tellT "collection" (collection msg)
       P'.tellT "definer" (definer msg)
       P'.tellT "algorithm" (algorithm msg)
       P'.tellT "security" (security msg)
       P'.tellT "check" (check msg)
       P'.tellT "column" (column msg)
       P'.tellT "stmt" (stmt msg)
       P'.tellT "replace_existing" (replace_existing msg)
  textGet
   = do
       mods <- P'.sepEndBy
                (P'.choice
                  [parse'collection, parse'definer, parse'algorithm, parse'security, parse'check, parse'column, parse'stmt,
                   parse'replace_existing])
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
        parse'replace_existing
         = P'.try
            (do
               v <- P'.getT "replace_existing"
               Prelude'.return (\ o -> o{replace_existing = v}))