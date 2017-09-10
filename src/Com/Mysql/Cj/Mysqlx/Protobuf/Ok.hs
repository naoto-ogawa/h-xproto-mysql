{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Ok (Ok(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data Ok = Ok{msg :: !(P'.Maybe P'.Utf8)}
        deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Ok where
  mergeAppend (Ok x'1) (Ok y'1) = Ok (P'.mergeAppend x'1 y'1)

instance P'.Default Ok where
  defaultValue = Ok P'.defaultValue

instance P'.Wire Ok where
  wireSize ft' self'@(Ok x'1)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeOpt 1 9 x'1)
  wirePut ft' self'@(Ok x'1)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutOpt 10 9 x'1
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             10 -> Prelude'.fmap (\ !new'Field -> old'Self{msg = Prelude'.Just new'Field}) (P'.wireGet 9)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> Ok) Ok where
  getVal m' f' = f' m'

instance P'.GPB Ok

instance P'.ReflectDescriptor Ok where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [10])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Ok\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Ok\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"Ok.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Ok.msg\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Ok\"], baseName' = FName \"msg\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType Ok where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg Ok where
  textPut msg'
   = do
       P'.tellT "msg" (msg msg')
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'msg]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'msg
         = P'.try
            (do
               v <- P'.getT "msg"
               Prelude'.return (\ o -> o{msg = v}))