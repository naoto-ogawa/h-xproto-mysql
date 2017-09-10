{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.CapabilitiesGet (CapabilitiesGet(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data CapabilitiesGet = CapabilitiesGet{}
                     deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable CapabilitiesGet where
  mergeAppend CapabilitiesGet CapabilitiesGet = CapabilitiesGet

instance P'.Default CapabilitiesGet where
  defaultValue = CapabilitiesGet

instance P'.Wire CapabilitiesGet where
  wireSize ft' self'@(CapabilitiesGet)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = 0
  wirePut ft' self'@(CapabilitiesGet)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             Prelude'.return ()
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> CapabilitiesGet) CapabilitiesGet where
  getVal m' f' = f' m'

instance P'.GPB CapabilitiesGet

instance P'.ReflectDescriptor CapabilitiesGet where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Connection.CapabilitiesGet\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"CapabilitiesGet\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"CapabilitiesGet.hs\"], isGroup = False, fields = fromList [], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType CapabilitiesGet where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg CapabilitiesGet where
  textPut msg = Prelude'.return ()
  textGet = Prelude'.return P'.defaultValue
    where