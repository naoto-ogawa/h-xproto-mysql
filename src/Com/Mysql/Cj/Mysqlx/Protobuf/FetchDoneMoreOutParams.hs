{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.FetchDoneMoreOutParams (FetchDoneMoreOutParams(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'

data FetchDoneMoreOutParams = FetchDoneMoreOutParams{}
                            deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable FetchDoneMoreOutParams where
  mergeAppend FetchDoneMoreOutParams FetchDoneMoreOutParams = FetchDoneMoreOutParams

instance P'.Default FetchDoneMoreOutParams where
  defaultValue = FetchDoneMoreOutParams

instance P'.Wire FetchDoneMoreOutParams where
  wireSize ft' self'@(FetchDoneMoreOutParams)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = 0
  wirePut ft' self'@(FetchDoneMoreOutParams)
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

instance P'.MessageAPI msg' (msg' -> FetchDoneMoreOutParams) FetchDoneMoreOutParams where
  getVal m' f' = f' m'

instance P'.GPB FetchDoneMoreOutParams

instance P'.ReflectDescriptor FetchDoneMoreOutParams where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Resultset.FetchDoneMoreOutParams\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"FetchDoneMoreOutParams\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"FetchDoneMoreOutParams.hs\"], isGroup = False, fields = fromList [], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType FetchDoneMoreOutParams where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg FetchDoneMoreOutParams where
  textPut msg = Prelude'.return ()
  textGet = Prelude'.return P'.defaultValue
    where