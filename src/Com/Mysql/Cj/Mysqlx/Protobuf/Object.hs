{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Object (Object(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Object.ObjectField as Com.Mysql.Cj.Mysqlx.Protobuf.Object (ObjectField)

data Object = Object{fld :: !(P'.Seq Com.Mysql.Cj.Mysqlx.Protobuf.Object.ObjectField)}
            deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Object where
  mergeAppend (Object x'1) (Object y'1) = Object (P'.mergeAppend x'1 y'1)

instance P'.Default Object where
  defaultValue = Object P'.defaultValue

instance P'.Wire Object where
  wireSize ft' self'@(Object x'1)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeRep 1 11 x'1)
  wirePut ft' self'@(Object x'1)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutRep 10 11 x'1
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             10 -> Prelude'.fmap (\ !new'Field -> old'Self{fld = P'.append (fld old'Self) new'Field}) (P'.wireGet 11)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> Object) Object where
  getVal m' f' = f' m'

instance P'.GPB Object

instance P'.ReflectDescriptor Object where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [10])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Datatypes.Object\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Object\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"Object.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Datatypes.Object.fld\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Object\"], baseName' = FName \"fld\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Datatypes.Object.ObjectField\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Object\"], baseName = MName \"ObjectField\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType Object where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg Object where
  textPut msg
   = do
       P'.tellT "fld" (fld msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'fld]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'fld
         = P'.try
            (do
               v <- P'.getT "fld"
               Prelude'.return (\ o -> o{fld = P'.append (fld o) v}))