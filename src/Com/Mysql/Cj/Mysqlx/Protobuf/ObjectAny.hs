{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.ObjectAny (ObjectAny(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ObjectAny.ObjectFieldAny as Com.Mysql.Cj.Mysqlx.Protobuf.ObjectAny (ObjectFieldAny)

data ObjectAny = ObjectAny{fld :: !(P'.Seq Com.Mysql.Cj.Mysqlx.Protobuf.ObjectAny.ObjectFieldAny)}
               deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable ObjectAny where
  mergeAppend (ObjectAny x'1) (ObjectAny y'1) = ObjectAny (P'.mergeAppend x'1 y'1)

instance P'.Default ObjectAny where
  defaultValue = ObjectAny P'.defaultValue

instance P'.Wire ObjectAny where
  wireSize ft' self'@(ObjectAny x'1)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeRep 1 11 x'1)
  wirePut ft' self'@(ObjectAny x'1)
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

instance P'.MessageAPI msg' (msg' -> ObjectAny) ObjectAny where
  getVal m' f' = f' m'

instance P'.GPB ObjectAny

instance P'.ReflectDescriptor ObjectAny where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [10])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Datatypes.ObjectAny\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ObjectAny\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"ObjectAny.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Datatypes.ObjectAny.fld\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ObjectAny\"], baseName' = FName \"fld\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Datatypes.ObjectAny.ObjectFieldAny\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"ObjectAny\"], baseName = MName \"ObjectFieldAny\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType ObjectAny where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg ObjectAny where
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