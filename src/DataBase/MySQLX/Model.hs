{- |
module      : Database.MySQLX.Model
description : crud interface 
copyright   : (c) naoto ogawa, 2017
license     : MIT 
maintainer  :  
stability   : experimental
portability : 

-}

{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE RecordWildCards      #-}

module DataBase.MySQLX.Model  where

import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Any.Type                           as PAT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Any                                as PA
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Array                              as PAR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.AuthenticateContinue               as PAC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.AuthenticateOk                     as PAO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.AuthenticateStart                  as PAS
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Capabilities                       as PCs
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.CapabilitiesGet                    as PCG
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.CapabilitiesSet                    as PCS
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Capability                         as PC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ClientMessages.Type                as PCMT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ClientMessages                     as PCM
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Close                              as PC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Collection                         as PCll
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Column                             as PCol
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnIdentifier                   as PCI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType           as PCMDFT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.CreateView                         as PCV
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DataModel                          as PDM
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Delete                             as PD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DocumentPathItem.Type              as PDPIT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DocumentPathItem                   as PDPI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DropView                           as PDV
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Error.Severity                     as PES 
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Error                              as PE 
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Expr.Type                          as PET
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Expr                               as PEx
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.FetchDone                          as PFD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.FetchDoneMoreOutParams             as PFDMOP
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.FetchDoneMoreResultsets            as PFDMR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find                               as PF
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Frame.Scope                        as PFS  
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Frame                              as PFr
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.FunctionCall                       as PFC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Identifier                         as PI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert.TypedRow                    as PITR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert                             as PI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Limit                              as PL
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ModifyView                         as PMV
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Object.ObjectField                 as POF
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Object                             as PO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ObjectExpr.ObjectFieldExpr         as POFE
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ObjectExpr                         as POE
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Ok                                 as POk
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition.ConditionOperation  as POCCO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Open.Condition                     as POC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Open.CtxOperation                  as POCtx
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Open                               as POp
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Operator                           as POpe
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Order.Direction                    as POD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Order                              as PO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Projection                         as PP
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Reset                              as PRe
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Row                                as PR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Scalar.Octets                      as PSO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Scalar.String                      as PSS
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Scalar.Type                        as PST
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Scalar                             as PS
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ServerMessages.Type                as PSMT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ServerMessages                     as PSM
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.SessionStateChanged.Parameter      as PSSCP
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.SessionStateChanged                as PSSC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.SessionVariableChanged             as PSVC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.StmtExecute                        as PSE
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.StmtExecuteOk                      as PSEO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Update                             as PU
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.UpdateOperation.UpdateType         as PUOUT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.UpdateOperation                    as PUO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ViewAlgorithm                      as PVA
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ViewCheckOption                    as PVCO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ViewSqlSecurity                    as PVSS
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Warning.Level                      as PWL
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Warning                            as PW
import qualified Com.Mysql.Cj.Mysqlx.Protobuf                                    as P'

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB
import qualified Text.ProtocolBuffers.Basic          as PBB
import qualified Text.ProtocolBuffers.Header         as PBH
import qualified Text.ProtocolBuffers.TextMessage    as PBT
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers.Reflections    as PBR

-- general, standard library
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import Data.ByteString.Builder
import Data.ByteString.Conversion.To
import qualified Data.Foldable        as F
import Data.Int                       as I
import Data.List (find)
import Data.Maybe                     as M
import Data.Sequence                  as Seq
import Data.String
import Data.Text                      as T
import Data.Text.Encoding             as TE
import Data.Typeable          (TypeRep, Typeable, typeRep, typeOf)
import Data.Word                      as W
import Data.Monoid

import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM)

import Control.Monad
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class

-- my library
import DataBase.MySQLX.Util
import DataBase.MySQLX.Exception

getMessage :: (MonadThrow m, PBW.Wire a, PBR.ReflectDescriptor a, PBT.TextMsg a, Typeable a) => B.ByteString -> m a 
getMessage bs = do
   case PBW.messageGet (BL.fromStrict bs) of
     Left  e -> error e -- throwM $ MessageGetException "foo" (typeOf bs)
     Right (w,_) -> return w 

--
--  ByteString -> m Model
--

-- mkAny.Type                            :: PAT  .Any.Type   
-- mkAny.Type                            = PB.defaultValue
getAny                                 :: (MonadThrow m) => B.ByteString -> m PA.Any 
getAny                                 = getMessage 
getArray                               :: (MonadThrow m) => B.ByteString -> m PAR.Array                              
getArray                               = getMessage
getAuthenticateContinue                :: (MonadThrow m) => B.ByteString -> m PAC.AuthenticateContinue
getAuthenticateContinue                = getMessage 
getAuthenticateOk                      :: (MonadThrow m) => B.ByteString -> m PAO.AuthenticateOk
getAuthenticateOk                      = getMessage 
getAuthenticateStart                   :: (MonadThrow m) => B.ByteString -> m PAS.AuthenticateStart                  
getAuthenticateStart                   = getMessage
getCapabilities                        :: (MonadThrow m) => B.ByteString -> m PCs.Capabilities                       
getCapabilities                        = getMessage
getCapabilitiesGet                     :: (MonadThrow m) => B.ByteString -> m PCG.CapabilitiesGet                    
getCapabilitiesGet                     = getMessage
getCapabilitiesSet                     :: (MonadThrow m) => B.ByteString -> m PCS.CapabilitiesSet                    
getCapabilitiesSet                     = getMessage
getCapability                          :: (MonadThrow m) => B.ByteString -> m PC.Capability                         
getCapability                          = getMessage
-- mkClientMessages.Type                 :: (MonadThrow m) => B.ByteString -> m PCMT.ClientMessages.Type                
-- mkClientMessages.Type                 = getMessage
getClientMessages                      :: (MonadThrow m) => B.ByteString -> m PCM.ClientMessages                     
getClientMessages                      = getMessage
getClose                               :: (MonadThrow m) => B.ByteString -> m PC.Close                              
getClose                               = getMessage
getCollection                          :: (MonadThrow m) => B.ByteString -> m PCll.Collection                         
getCollection                          = getMessage
getColumn                              :: (MonadThrow m) => B.ByteString -> m PCol.Column                             
getColumn                              = getMessage
getColumnIdentifier                    :: (MonadThrow m) => B.ByteString -> m PCI.ColumnIdentifier 
getColumnIdentifier                    = getMessage
-- mkColumnMetaData.FieldType            :: (MonadThrow m) => B.ByteString -> m PCMD.ColumnMetaData.FieldType           
-- mkColumnMetaData.FieldType            = getMessage
getColumnMetaData                      :: (MonadThrow m) => B.ByteString -> m PCMD.ColumnMetaData                     
getColumnMetaData                      = getMessage
getCreateView                          :: (MonadThrow m) => B.ByteString -> m PCV.CreateView                         
getCreateView                          = getMessage
-- getDataModel                           :: (MonadThrow m) => B.ByteString -> m PDM.DataModel                          
-- getDataModel                           = getMessage
getDelete                              :: (MonadThrow m) => B.ByteString -> m PD.Delete                             
getDelete                              = getMessage
-- mkDocumentPathItem.Type               :: (MonadThrow m) => B.ByteString -> m PDPI.DocumentPathItem.Type              
-- mkDocumentPathItem.Type               = getMessage
getDocumentPathItem                    :: (MonadThrow m) => B.ByteString -> m PDPI.DocumentPathItem                   
getDocumentPathItem                    = getMessage
getDropView                            :: (MonadThrow m) => B.ByteString -> m PDV.DropView                           
getDropView                            = getMessage
-- mkError.Severity                      :: (MonadThrow m) => B.ByteString -> m PE.Error.Severity                     
-- mkError.Severity                      = getMessage
getError                               :: (MonadThrow m) => B.ByteString -> m PE.Error
getError                               = getMessage 
-- mkExpr.Type                           :: PEx.Expr.Type                          
-- mkExpr.Type                           = getMessage
getExpr                                :: (MonadThrow m) => B.ByteString -> m PEx.Expr                               
getExpr                                = getMessage
getFetchDone                           :: (MonadThrow m) => B.ByteString -> m PFD.FetchDone                          
getFetchDone                           = getMessage
getFetchDoneMoreOutParams              :: (MonadThrow m) => B.ByteString -> m PFDMOP.FetchDoneMoreOutParams             
getFetchDoneMoreOutParams              = getMessage
getFetchDoneMoreResultsets             :: (MonadThrow m) => B.ByteString -> m PFDMR.FetchDoneMoreResultsets            
getFetchDoneMoreResultsets             = getMessage
getFind                                :: (MonadThrow m) => B.ByteString -> m PF.Find                               
getFind                                = getMessage
-- mkFrame.Scope                         :: (MonadThrow m) => B.ByteString -> m PFr.Frame.Scope                        
-- mkFrame.Scope                         = getMessage
{-
Frame Structure

type  local global   payload
1       *     *      Warning
2       *     -      SessionVariableChanged
3       *     -      SessionStateChanged
-}
getFrame                               :: (MonadThrow m) => B.ByteString -> m PFr.Frame
getFrame                               = getMessage 

-- | Warning Frame Type 
frame_warning :: W.Word32
frame_warning = 1 

-- | Session Variable Chagend Frame Type 
frame_session_variable_changed :: W.Word32
frame_session_variable_changed = 2

-- | Session State Chagend Frame Type 
frame_session_state_changed :: W.Word32
frame_session_state_changed = 3

getFramePayload :: (MonadThrow m) => PFr.Frame -> m B.ByteString
getFramePayload frame = do 
  case PFr.payload frame of
    Nothing -> throwM $ XProtocolException "tPayload is Nothing" 
    Just p  -> return $ BL.toStrict p

getPayloadWarning ::  (MonadThrow m) => PFr.Frame -> m PW.Warning
getPayloadWarning x = getFramePayload x >>= getWarning 

getPayloadSessionStateChanged ::  (MonadThrow m) => PFr.Frame -> m PSSC.SessionStateChanged 
getPayloadSessionStateChanged x = getFramePayload x >>= getSessionStateChanged 

getPayloadSessionVariableChanged ::  (MonadThrow m) => PFr.Frame -> m PSVC.SessionVariableChanged 
getPayloadSessionVariableChanged x = getFramePayload x >>= getSessionVariableChanged

getFunctionCall                        :: (MonadThrow m) => B.ByteString -> m PFC.FunctionCall                       
getFunctionCall                        = getMessage
getIdentifier                          :: (MonadThrow m) => B.ByteString -> m PI.Identifier                         
getIdentifier                          = getMessage
getTypedRow                            :: (MonadThrow m) => B.ByteString -> m PITR.TypedRow                    
getTypedRow                            = getMessage
getInsert                              :: (MonadThrow m) => B.ByteString -> m PI.Insert                             
getInsert                              = getMessage
getLimit                               :: (MonadThrow m) => B.ByteString -> m PL.Limit                              
getLimit                               = getMessage
getModifyView                          :: (MonadThrow m) => B.ByteString -> m PMV.ModifyView                         
getModifyView                          = getMessage
getObjectField                         :: (MonadThrow m) => B.ByteString -> m POF.ObjectField                 
getObjectField                         = getMessage
getObject                              :: (MonadThrow m) => B.ByteString -> m PO.Object                             
getObject                              = getMessage
getOk                                  :: (MonadThrow m) => B.ByteString -> m POk.Ok                                 
getOk                                  = getMessage
-- mkOpen.Condition.ConditionOperation   :: (MonadThrow m) => B.ByteString -> m POC.Open.Condition.ConditionOperation  
-- mkOpen.Condition.ConditionOperation   = getMessage
getCondition                           :: (MonadThrow m) => B.ByteString -> m POC.Condition                     
getCondition                           = getMessage
-- mkOpen.CtxOperation                   :: (MonadThrow m) => B.ByteString -> m POe.Open.CtxOperation                  
-- mkOpen.CtxOperation                   = getMessage
getOpen                                :: (MonadThrow m) => B.ByteString -> m POp.Open                               
getOpen                                = getMessage
getOperator                            :: (MonadThrow m) => B.ByteString -> m POpe.Operator                           
getOperator                            = getMessage
-- mkOrder.Direction                     :: (MonadThrow m) => B.ByteString -> m POD.Order.Direction                    
-- mkOrder.Direction                     = getMessage
getOrder                               :: (MonadThrow m) => B.ByteString -> m PO.Order                              
getOrder                               = getMessage
getProjection                          :: (MonadThrow m) => B.ByteString -> m PP.Projection                         
getProjection                          = getMessage
getReset                               :: (MonadThrow m) => B.ByteString -> m PRe.Reset                              
getReset                               = getMessage
getRow                                 :: (MonadThrow m) => B.ByteString -> m PR.Row                                
getRow                                 = getMessage
getScalarOctets                        :: (MonadThrow m) => B.ByteString -> m PSO.Octets                      
getScalarOctets                        = getMessage
getScalarString                        :: (MonadThrow m) => B.ByteString -> m PSS.String                      
getScalarString                        = getMessage
-- mkScalar.Type                         :: (MonadThrow m) => B.ByteString -> m PST.Scalar.Type                        
-- mkScalar.Type                         = getMessage
getScalar                              :: (MonadThrow m) => B.ByteString -> m PS.Scalar                             
getScalar                              = getMessage
-- mkServerMessages.Type                 :: (MonadThrow m) => B.ByteString -> m PSMT.ServerMessages.Type                
-- mkServerMessages.Type                 = getMessage
getServerMessages                      :: (MonadThrow m) => B.ByteString -> m PSM.ServerMessages                     
getServerMessages                      = getMessage
-- mkSessionStateChanged.Parameter       :: (MonadThrow m) => B.ByteString -> m PSSCP.SessionStateChanged.Parameter      
-- mkSessionStateChanged.Parameter       = getMessage
getSessionStateChanged                 :: (MonadThrow m) => B.ByteString -> m PSSC.SessionStateChanged                
getSessionStateChanged                 = getMessage
getSessionVariableChanged              :: (MonadThrow m) => B.ByteString -> m PSVC.SessionVariableChanged             
getSessionVariableChanged              = getMessage
getStmtExecute                         :: (MonadThrow m) => B.ByteString -> m PSE.StmtExecute                        
getStmtExecute                         = getMessage
getStmtExecuteOk                       :: (MonadThrow m) => B.ByteString -> m PSEO.StmtExecuteOk                      
getStmtExecuteOk                       = getMessage
getUpdate                              :: (MonadThrow m) => B.ByteString -> m PU.Update                             
getUpdate                              = getMessage
-- mkUpdateOperation.UpdateType          :: (MonadThrow m) => B.ByteString -> m PUOUT.UpdateOperation.UpdateType         
-- mkUpdateOperation.UpdateType          = getMessage
getUpdateOperation                     :: (MonadThrow m) => B.ByteString -> m PUO.UpdateOperation                    
getUpdateOperation                     = getMessage
-- getViewAlgorithm                       :: (MonadThrow m) => B.ByteString -> m PVA.ViewAlgorithm                      
-- getViewAlgorithm                       = getMessage
-- getViewCheckOption                     :: (MonadThrow m) => B.ByteString -> m PVCO.ViewCheckOption                    
-- getViewCheckOption                     = getMessage
-- getViewSqlSecurity                     :: (MonadThrow m) => B.ByteString -> m PVSS.ViewSqlSecurity                    
-- getViewSqlSecurity                     = getMessage
-- mkWarning.Level                       :: (MonadThrow m) => B.ByteString -> m PWL.Warning.Level                      
-- mkWarning.Level                       = getMessage

{-
data Warning = Warning{level :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Warning.Level), code :: !(P'.Word32), msg :: !(P'.Utf8)}
data Level = NOTE | WARNING | ERROR
-}

-- | Make a Warning instance from ByteString.
getWarning                             :: (MonadThrow m) => B.ByteString -> m PW.Warning                            
getWarning                             = getMessage

--
--  Various data -> m Model
--

mkAnyType                             :: PAT.Type   
mkAnyType                             = PB.defaultValue
{-
Any :: data Type = SCALAR | OBJECT | ARRAY 
-}
-- mkAny                                 :: PA.Any 
-- mkAny                                 = PB.defaultValue

-- | Make a SCALAR type Any. Don't use this function, use any. (TODO hiding)
mkAnyScalar :: PS.Scalar -> PA.Any
mkAnyScalar x = PB.defaultValue {PA.type' = PAT.SCALAR, PA.scalar = Just x}

-- | Make an OBJECT type Any. Don't use this function, use any. (TODO hiding)
mkAnyObject :: PO.Object -> PA.Any
mkAnyObject x = PB.defaultValue {PA.type' = PAT.OBJECT, PA.obj = Just x}

-- | Make a ARRAY type Any. Don't use this function, use any. (TODO hiding)
mkAnyArray :: PAR.Array -> PA.Any
mkAnyArray x = PB.defaultValue {PA.type' = PAT.ARRAY, PA.array = Just x}

{-
data Any = Any{
    type'  :: !(Com.Mysql.Cj.Mysqlx.Protobuf.Any.Type)
  , scalar :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Scalar)
  , obj    :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Object)
  , array  :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Array)
}

Int, Int64, Word8, Word64, Double, Float, Bool, String, Text, Object, Array,

-}

-- | Make an Any instance.
class    Anyable a        where 
  -- | Make an Any instance.
  any :: a -> PA.Any
  -- | Make a list of Any instance.
  anys :: [a] -> [PA.Any] 
  anys = Prelude.map DataBase.MySQLX.Model.any 
instance Anyable Int       where any = mkAnyScalar . scalar
instance Anyable Int64     where any = mkAnyScalar . scalar
instance Anyable Word8     where any = mkAnyScalar . scalar
instance Anyable Word64    where any = mkAnyScalar . scalar
instance Anyable Double    where any = mkAnyScalar . scalar
instance Anyable Float     where any = mkAnyScalar . scalar
instance Anyable Bool      where any = mkAnyScalar . scalar
instance Anyable String    where any = mkAnyScalar . scalar
instance Anyable Text      where any = mkAnyScalar . scalar
instance Anyable PS.Scalar where any = mkAnyScalar
instance Anyable PO.Object where any = mkAnyObject
instance Anyable PAR.Array where any = mkAnyArray

-- data Array = Array{value :: !(P'.Seq Com.Mysql.Cj.Mysqlx.Protobuf.Expr)}
-- | Make a Array instance.
mkArray :: [PEx.Expr] -> PAR.Array                              
mkArray xs = PAR.Array {value = Seq.fromList xs}

-- | Make an authenticate continue instance.
mkAuthenticateContinue :: (ToByteString a, ToByteString b, ToByteString c, ToByteString d) 
  => a -- ^ Database name
  -> b -- ^ User name
  -> c -- ^ Salt, which is given by MySQL Server.
  -> d -- ^ Password
  -> PAC.AuthenticateContinue               
mkAuthenticateContinue dbname username salt pw = PB.defaultValue { 
     PAC.auth_data = toLazyByteString $  
           builder dbname 
        <> builder ("\x00"  :: String) 
        <> builder username 
        <> builder ("\x00*" :: String) 
        <> builder (toHex' $ getPasswordHash salt pw)
     }

mkAuthenticateOk                      :: (MonadThrow m) => B.ByteString -> m PAO.AuthenticateOk
mkAuthenticateOk                      = getMessage 

-- | Make an authenticate start instance.
mkAuthenticateStart :: (ToByteString a) 
  => a  -- ^ User name 
  -> PAS.AuthenticateStart                  
mkAuthenticateStart user = PB.defaultValue {
    PAS.mech_name = PBH.uFromString "MYSQL41"
  , PAS.auth_data = Just $ toByteString user
  }

mkCapabilities                        :: PCs.Capabilities                       
mkCapabilities                        = PB.defaultValue
mkCapabilitiesGet                     :: PCG.CapabilitiesGet                    
mkCapabilitiesGet                     = PB.defaultValue
mkCapabilitiesSet                     :: PCS.CapabilitiesSet                    
mkCapabilitiesSet                     = PB.defaultValue
mkCapability                          :: PC.Capability                         
mkCapability                          = PB.defaultValue
mkClientMessagesType                 :: PCMT.Type                
mkClientMessagesType                 = PB.defaultValue
mkClientMessages                      :: PCM.ClientMessages                     
mkClientMessages                      = PB.defaultValue
mkClose                               :: PC.Close                              
mkClose                               = PB.defaultValue

{- Collection -}
-- | Make a collection instance.
mkCollection :: 
     String  -- ^ schema
  -> String  -- ^ collection name
  -> PCll.Collection
mkCollection schema name = PCll.Collection (PBH.uFromString name) (Just $ PBH.uFromString schema)

-- | Make a collection instance without a schema name.
mkCollection' :: 
     String  -- ^ collection name
  -> PCll.Collection
mkCollection' name = PCll.Collection (PBH.uFromString name) Nothing

mkColumn                              :: PCol.Column                             
mkColumn                              = PB.defaultValue

{- ColumnIdentifier -}
mkColumnIdentifier                    :: PCI.ColumnIdentifier 
mkColumnIdentifier                    = PB.defaultValue

columnIdentifierDocumentPahtItem :: [PDPI.DocumentPathItem] -> PCI.ColumnIdentifier 
columnIdentifierDocumentPahtItem docpathItems = PB.defaultValue {PCI.document_path = Seq.fromList docpathItems} 

columnIdentifierName :: String -> PCI.ColumnIdentifier 
columnIdentifierName x = PB.defaultValue {PCI.name = Just $ PBH.uFromString x} 

columnIdentifierTableName :: String -> PCI.ColumnIdentifier 
columnIdentifierTableName x = PB.defaultValue {PCI.table_name = Just $ PBH.uFromString x} 

columnIdentifierSchemaName :: String -> PCI.ColumnIdentifier 
columnIdentifierSchemaName x = PB.defaultValue {PCI.schema_name = Just $ PBH.uFromString x} 

columnIdentifier'' :: String -> String -> PCI.ColumnIdentifier
columnIdentifier'' table name = PB.defaultValue {
   PCI.table_name = Just $ PBH.uFromString table
  ,PCI.name       = Just $ PBH.uFromString name
  }

columnIdentifier''' :: String -> String -> String -> PCI.ColumnIdentifier
columnIdentifier''' schema table name = PB.defaultValue {
   PCI.schema_name = Just $ PBH.uFromString schema
  ,PCI.table_name  = Just $ PBH.uFromString table
  ,PCI.name        = Just $ PBH.uFromString name
  } 

mkColumnMetaDataFieldType             :: PCMDFT.FieldType           
mkColumnMetaDataFieldType             = PB.defaultValue
mkColumnMetaData                      :: PCMD.ColumnMetaData                     
mkColumnMetaData                      = PB.defaultValue
{-
data ColumnMetaData = ColumnMetaData{type' :: !(Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType),
                                     name :: !(P'.Maybe P'.ByteString), original_name :: !(P'.Maybe P'.ByteString),
                                     table :: !(P'.Maybe P'.ByteString), original_table :: !(P'.Maybe P'.ByteString),
                                     schema :: !(P'.Maybe P'.ByteString), catalog :: !(P'.Maybe P'.ByteString),
                                     collation :: !(P'.Maybe P'.Word64), fractional_digits :: !(P'.Maybe P'.Word32),
                                     length :: !(P'.Maybe P'.Word32), flags :: !(P'.Maybe P'.Word32),
                                     content_type :: !(P'.Maybe P'.Word32)}
-}

getColumnType :: PCMD.ColumnMetaData -> PCMDFT.FieldType
getColumnType = PCMD.type'

getColumnName :: PCMD.ColumnMetaData -> T.Text
getColumnName = _maybeByteString2Text . PCMD.name 

getColumnOriginalName :: PCMD.ColumnMetaData -> T.Text
getColumnOriginalName = _maybeByteString2Text . PCMD.original_name 

getColumnTable :: PCMD.ColumnMetaData -> T.Text
getColumnTable = _maybeByteString2Text . PCMD.table 

getColumnOriginalTalbe :: PCMD.ColumnMetaData -> T.Text
getColumnOriginalTalbe = _maybeByteString2Text . PCMD.original_table 

getColumnSchema :: PCMD.ColumnMetaData -> T.Text
getColumnSchema = _maybeByteString2Text . PCMD.schema 

getColumnCatalog :: PCMD.ColumnMetaData -> T.Text
getColumnCatalog = _maybeByteString2Text . PCMD.catalog

getColumnCollation :: PCMD.ColumnMetaData -> W.Word64 
getColumnCollation meta = fromMaybe 0 $ PCMD.collation meta

getColumnFractionalDigits :: PCMD.ColumnMetaData -> W.Word32
getColumnFractionalDigits meta = fromMaybe 0 $ PCMD.fractional_digits meta

getColumnLength :: PCMD.ColumnMetaData -> W.Word32
getColumnLength meta = fromMaybe 0 $ PCMD.length meta

getColumnFlags :: PCMD.ColumnMetaData -> W.Word32
getColumnFlags meta = fromMaybe 0 $ PCMD.flags meta

_maybeByteString2Text :: Maybe BL.ByteString -> T.Text 
_maybeByteString2Text = TE.decodeUtf8 . BL.toStrict . M.fromJust 

-- //   BYTES  0x0001 GEOMETRY (WKB encoding)
-- //   BYTES  0x0002 JSON (text encoding)
-- //   BYTES  0x0003 XML (text encoding)
data ColumnContentType = GEOMETRY | JSON | XML | NONE

getContentType :: PCMD.ColumnMetaData -> ColumnContentType
getContentType meta = 
  case PCMD.content_type meta of
    Nothing -> NONE
    Just x  -> 
      case x of
        1 -> GEOMETRY
        2 -> JSON
        3 -> XML
        _ -> NONE

mkCreateView                          :: PCV.CreateView                         
mkCreateView                          = PB.defaultValue
mkDataModel                           :: PDM.DataModel                          
mkDataModel                           = PB.defaultValue
mkDelete                              :: PD.Delete                             
mkDelete                              = PB.defaultValue
mkDocumentPathItemType                :: PDPIT.Type              
mkDocumentPathItemType                = PB.defaultValue

{- DocumentPathItem -}
mkDocumentPathItem :: String -> PDPI.DocumentPathItem 
mkDocumentPathItem ('*':'*':_     ) = PB.defaultValue { PDPI.type' = PDPIT.DOUBLE_ASTERISK }
mkDocumentPathItem ('*':_         ) = PB.defaultValue { PDPI.type' = PDPIT.MEMBER_ASTERISK }
mkDocumentPathItem ('[':'*':']':_ ) = PB.defaultValue { PDPI.type' = PDPIT.ARRAY_INDEX_ASTERISK }
mkDocumentPathItem ('[':xs        ) = PB.defaultValue { PDPI.type' = PDPIT.ARRAY_INDEX         , PDPI.index =  Just $ (read (Prelude.init xs) :: Word32) }
mkDocumentPathItem (x             ) = PB.defaultValue { PDPI.type' = PDPIT.MEMBER              , PDPI.value =  Just $ PBH.uFromString x }

mkDropView                            :: PDV.DropView                           
mkDropView                            = PB.defaultValue
mkErrorSeverity                       :: PES.Severity 
mkErrorSeverity                       = PB.defaultValue
mkError                               :: PE.Error                              
mkError                               = PB.defaultValue
mkExprType                            :: PET.Type                          
mkExprType                            = PB.defaultValue
{- Expr 
   Type = IDENT | LITERAL | VARIABLE | FUNC_CALL | OPERATOR | PLACEHOLDER | OBJECT | ARRAY
-}
mkExpr                                :: PEx.Expr                               
mkExpr                                = PB.defaultValue


-- | Make an Expr instance and Retrieve a value from Expr
class Exprable a where 
  -- | Make an Expr instance.
  expr    :: a -> PEx.Expr 
  -- | Retrieve a value from Expr safely.
  exprVal :: PEx.Expr -> Maybe a
  exprVal = error "not implmented. Submit an issue." -- undefined      -- TODO impiementations
  -- | Retrieve a value from Expr.
  exprVal' :: PEx.Expr -> a
  exprVal' = M.fromJust . exprVal 

-- LITERAL
instance Exprable Int     where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal
instance Exprable Int64   where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal
instance Exprable Word8   where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal
instance Exprable Word64  where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal
instance Exprable Double  where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal
instance Exprable Float   where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal
instance Exprable Bool    where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal
instance Exprable String  where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal
instance Exprable T.Text  where 
  expr    = exprLiteral . scalar
  exprVal = join . fmap getScalarVal . PEx.literal

-- FUNC_CALL
instance Exprable PFC.FunctionCall where 
  expr a  = PB.defaultValue {PEx.type' = PET.FUNC_CALL , PEx.function_call = Just a}
  exprVal = PEx.function_call 

-- OBJECT 
instance Exprable POE.ObjectExpr where 
  expr a = PB.defaultValue {PEx.type' = PET.OBJECT    , PEx.object        = Just a}
  exprVal = PEx.object

-- ObjectFieldExpr -> OBJECT
instance Exprable [POFE.ObjectFieldExpr] where 
  expr as = expr $ setObjectExpr as
  exprVal = fmap F.toList . fmap POE.fld . PEx.object

-- ARRAY
instance Exprable PAR.Array where
  expr a  = PB.defaultValue {PEx.type' = PET.ARRAY     , PEx.array         = Just a}
  exprVal = PEx.array

-- | Make a type LITERAL Expr.
exprLiteral :: PS.Scalar -> PEx.Expr
exprLiteral x = PB.defaultValue {PEx.type' = PET.LITERAL, PEx.literal = Just $ x}

-- | Make a Null Expr.
mkNullExpr :: PEx.Expr
mkNullExpr = exprLiteral mkNullScalar 

exprColumnIdentifier :: PCI.ColumnIdentifier -> PEx.Expr
exprColumnIdentifier colIdent = PB.defaultValue {PEx.type' = PET.IDENT, PEx.identifier = Just $ colIdent} 

exprPlaceholder :: Int -> PEx.Expr
exprPlaceholder pos = PB.defaultValue {PEx.type' = PET.PLACEHOLDER, PEx.position = Just $ fromIntegral pos }

-- | 1st placeholder.
ph1 = exprPlaceholder 1
-- | 2nd placeholder.
ph2 = exprPlaceholder 2
-- | 3rd placeholder.
ph3 = exprPlaceholder 3
-- | 4th placeholder.
ph4 = exprPlaceholder 4
-- | 5th placeholder.
ph5 = exprPlaceholder 5
-- | 6th placeholder.
ph6 = exprPlaceholder 6
-- | 7th placeholder.
ph7 = exprPlaceholder 7
-- | 8th placeholder.
ph8 = exprPlaceholder 8
-- | 9th placeholder.
ph9 = exprPlaceholder 9

exprIdentifierName :: String -> PEx.Expr
exprIdentifierName = exprColumnIdentifier . columnIdentifierName

exprDocumentPathItem :: String -> PEx.Expr
exprDocumentPathItem docPath = exprColumnIdentifier $ columnIdentifierDocumentPahtItem [mkDocumentPathItem docPath]

mkFetchDone                           :: PFD.FetchDone                          
mkFetchDone                           = PB.defaultValue
mkFetchDoneMoreOutParams              :: PFDMOP.FetchDoneMoreOutParams             
mkFetchDoneMoreOutParams              = PB.defaultValue
mkFetchDoneMoreResultsets             :: PFDMR.FetchDoneMoreResultsets            
mkFetchDoneMoreResultsets             = PB.defaultValue
mkFind                                :: PF.Find                               
mkFind                                = PB.defaultValue
mkFrameScope                          :: PFS.Scope                        
mkFrameScope                          = PB.defaultValue
mkFrame                               :: PFr.Frame                              
mkFrame                               = PB.defaultValue

{- FunctionCall -}
-- | Make a function call instance.
mkFunctionCall :: 
     String             -- ^ function name
  -> [PEx.Expr]         -- ^ parameters
  -> PFC.FunctionCall
mkFunctionCall name params = PFC.FunctionCall (mkIdentifier' name) (Seq.fromList params) 

{- Identifier -}
mkIdentifier :: String -> String -> PI.Identifier
mkIdentifier x schema = PI.Identifier (PBH.uFromString x) (Just $ PBH.uFromString schema)

mkIdentifier' :: String -> PI.Identifier
mkIdentifier' x = PI.Identifier (PBH.uFromString x) Nothing

{- TypedRow -}
mkTypedRow                            :: PITR.TypedRow                    
mkTypedRow                            = PB.defaultValue

-- | make a TypedRow instance which has multiple Exprs.
mkExpr2TypedRow :: [PEx.Expr] -> PITR.TypedRow
mkExpr2TypedRow fields = PITR.TypedRow $ Seq.fromList fields

-- | make a TypedRow instance which has one Expr.
mkExpr2TypedRow' :: PEx.Expr -> PITR.TypedRow
mkExpr2TypedRow' field = PITR.TypedRow $ Seq.singleton field

{- Insert -}
mkInsert                              :: PI.Insert                             
mkInsert                              = PB.defaultValue

fmapInsertRow :: (PITR.TypedRow -> PITR.TypedRow) -> PI.Insert -> PI.Insert
fmapInsertRow f ins = ins {PI.row = fmap f (PI.row ins)}

mkInsertX :: String -> String -> String -> PI.Insert 
mkInsertX schema table json = PB.defaultValue {
     PI.collection = mkCollection schema table
    ,PI.data_model  = Just PDM.DOCUMENT
    ,PI.projection  = Seq.empty
    ,PI.row         = Seq.singleton $ mkExpr2TypedRow' $ expr json 
    ,PI.args        = Seq.empty
  }

mkLimit                               :: PL.Limit                              
mkLimit                               = PB.defaultValue
mkModifyView                          :: PMV.ModifyView                         
mkModifyView                          = PB.defaultValue
{- ObjectField -}
mkObjectField :: String -> PA.Any -> POF.ObjectField
mkObjectField k a = POF.ObjectField {POF.key = (PBH.uFromString k), POF.value = a}

{- ObjectFieldExpr -}
mkObjectFieldExpr :: String -> PEx.Expr -> POFE.ObjectFieldExpr
mkObjectFieldExpr k a = POFE.ObjectFieldExpr {POFE.key = (PBH.uFromString k), POFE.value = a}

{- Object -}
mkObject                              :: PO.Object                             
mkObject                              = PB.defaultValue

setObject :: [POF.ObjectField] -> PO.Object
setObject xs = PO.Object $ Seq.fromList xs

{- ObjectExpr -}
mkObjectExpr                          :: POE.ObjectExpr                             
mkObjectExpr                          = PB.defaultValue

setObjectExpr :: [POFE.ObjectFieldExpr] -> POE.ObjectExpr
setObjectExpr xs = POE.ObjectExpr $ Seq.fromList xs

mkOk                                  :: POk.Ok                                 
mkOk                                  = PB.defaultValue


-- mkOpenConditionOperation              :: POCCO.ConditionOperation  
-- mkOpenConditionOperation              = PB.defaultValue
mkCondition                           :: POC.Condition                     
mkCondition                           = PB.defaultValue

{-
see https://github.com/mysql/mysql-server/blob/5.7/rapid/plugin/x/src/expect.cc
-}

-- | Make Condition opSet Set, if not set or overwrite, if set.
mkCondtinonOpSet :: POC.Condition -> POC.Condition
mkCondtinonOpSet condition = condition {POC.op = Just $ POCCO.EXPECT_OP_SET}  

-- | Unset the condition.
mkCondtinonOpUnset :: POC.Condition -> POC.Condition
mkCondtinonOpUnset condition = condition {POC.op = Just $ POCCO.EXPECT_OP_UNSET}  

-- | Make NO_ERROR Condition.
mkConditionNoError :: POC.Condition
mkConditionNoError = PB.defaultValue {POC.condition_key = condition_no_error}

-- -- | Make NO_ERROR Condition Unset.
-- mkConditionNoErrorUnset :: POC.Condition
-- mkConditionNoErrorUnset = mkCondtinonOpSet $ PB.defaultValue {POC.condition_key = condition_no_error}
-- 
condition_no_error               = 1 :: Word32
condition_schema_version         = 2 :: Word32
condition_gtid_executed_contains = 3 :: Word32
condition_gtid_wait_less_than_ms = 4 :: Word32

-- mkOpenCtxOperation                    :: POCtx.CtxOperation                  
-- mkOpenCtxOperation                    = PB.defaultValue

{-
data Open = Open{op :: !(P'.Maybe CtxOperation), cond :: !(P'.Seq Condition)}
data CtxOperation = EXPECT_CTX_COPY_PREV | EXPECT_CTX_EMPTY
-}
mkOpen                                :: POp.Open                               
mkOpen                                = PB.defaultValue

-- | Expectation
mkExpectCtxCopyPrev :: POp.Open 
mkExpectCtxCopyPrev = POp.Open (Just POCtx.EXPECT_CTX_COPY_PREV) Seq.empty

-- | +No Error Expectation
mkExpectNoError :: POp.Open
mkExpectNoError = POp.Open (Just POCtx.EXPECT_CTX_EMPTY) (Seq.singleton mkConditionNoError) 

-- | -No Error Expectation (Don't use No Error explicitly)
mkExpectUnset :: POp.Open
mkExpectUnset = POp.Open (Just POCtx.EXPECT_CTX_EMPTY) (Seq.empty) 




{-Operator -}
--   Unary                                                  TODO 
--   Using special representation, with more than 2 params  TODO
--   Ternary                                                TODO
--   Units for date_add/date_sub                            TODO
--   Types for cast                                         TODO
--   Binary
mkOperatorAnd     = POpe.Operator {POpe.name = PB.fromString "&&"         , POpe.param = Seq.empty} --  TODO type signature
mkOperatorOr      = POpe.Operator {POpe.name = PB.fromString "||"         , POpe.param = Seq.empty}
mkOperatorXor     = POpe.Operator {POpe.name = PB.fromString "xor"        , POpe.param = Seq.empty} 
mkOperatorEq      = POpe.Operator {POpe.name = PB.fromString "=="         , POpe.param = Seq.empty}
mkOperatorNotEq   = POpe.Operator {POpe.name = PB.fromString "!="         , POpe.param = Seq.empty}
mkOperatorGt      = POpe.Operator {POpe.name = PB.fromString ">"          , POpe.param = Seq.empty}
mkOperatorGte     = POpe.Operator {POpe.name = PB.fromString ">="         , POpe.param = Seq.empty}
mkOperatorSt      = POpe.Operator {POpe.name = PB.fromString "<"          , POpe.param = Seq.empty}
mkOperatorSte     = POpe.Operator {POpe.name = PB.fromString "<="         , POpe.param = Seq.empty}
mkOperatorShiftL  = POpe.Operator {POpe.name = PB.fromString "<<"         , POpe.param = Seq.empty}
mkOperatorShiftR  = POpe.Operator {POpe.name = PB.fromString "??"         , POpe.param = Seq.empty}
mkOperatorPlus    = POpe.Operator {POpe.name = PB.fromString "+"          , POpe.param = Seq.empty}
mkOperatorMinus   = POpe.Operator {POpe.name = PB.fromString "-"          , POpe.param = Seq.empty}
mkOperatorMultpl  = POpe.Operator {POpe.name = PB.fromString "*"          , POpe.param = Seq.empty}
mkOperatorDivid   = POpe.Operator {POpe.name = PB.fromString "/"          , POpe.param = Seq.empty}
mkOperatorRem     = POpe.Operator {POpe.name = PB.fromString "%"          , POpe.param = Seq.empty}
mkOperatorIs      = POpe.Operator {POpe.name = PB.fromString "is"         , POpe.param = Seq.empty}
mkOperatorIsNot   = POpe.Operator {POpe.name = PB.fromString "is_not"     , POpe.param = Seq.empty}
mkOperatorReg     = POpe.Operator {POpe.name = PB.fromString "regexp"     , POpe.param = Seq.empty}
mkOperatorNotReg  = POpe.Operator {POpe.name = PB.fromString "not_regexp" , POpe.param = Seq.empty}
mkOperatorLike    = POpe.Operator {POpe.name = PB.fromString "like"       , POpe.param = Seq.empty}
mkOperatorNotLike = POpe.Operator {POpe.name = PB.fromString "not_like"   , POpe.param = Seq.empty}
mkOperatorCast    = POpe.Operator {POpe.name = PB.fromString "cast"       , POpe.param = Seq.empty}

(@&&) :: PEx.Expr -> PEx.Expr -> PEx.Expr
(@&&) = binaryOperator mkOperatorAnd

(@||)        = binaryOperator mkOperatorOr      -- TODO type signature 
(xor)        = binaryOperator mkOperatorXor       
(@==)        = binaryOperator mkOperatorEq      
(@!=)        = binaryOperator mkOperatorNotEq 
(@>)         = binaryOperator mkOperatorGt 
(@>=)        = binaryOperator mkOperatorGte 
(@<)         = binaryOperator mkOperatorSt 
(@<=)        = binaryOperator mkOperatorSte 
(@<<)        = binaryOperator mkOperatorShiftL 
(@??)        = binaryOperator mkOperatorShiftR 
(@+)         = binaryOperator mkOperatorPlus 
(@-)         = binaryOperator mkOperatorMinus 
(@*)         = binaryOperator mkOperatorMultpl 
(@/)         = binaryOperator mkOperatorDivid 
(@%)         = binaryOperator mkOperatorRem 
(is)         = binaryOperator mkOperatorIs 
(is_not)     = binaryOperator mkOperatorIsNot
(regexp)     = binaryOperator mkOperatorReg 
(not_regexp) = binaryOperator mkOperatorNotReg 
(like)       = binaryOperator mkOperatorLike 
(not_like)   = binaryOperator mkOperatorNotLike 
(cast)       = binaryOperator mkOperatorCast 

binaryOperator :: POpe.Operator -> PEx.Expr -> PEx.Expr -> PEx.Expr 
binaryOperator ope a b = PB.defaultValue { PEx.type' = PET.OPERATOR, PEx.operator = Just $ ope {POpe.param = Seq.fromList [a,b] } } 

mkOrderDirection                      :: POD.Direction                    
mkOrderDirection                      = PB.defaultValue
mkOrder                               :: PO.Order                              
mkOrder                               = PB.defaultValue

{- Projection -}
mkProjection :: PEx.Expr -> String -> PP.Projection
mkProjection expr alias = PP.Projection {PP.source = expr, PP.alias = Just $ PBH.uFromString alias}

mkProjection' :: PEx.Expr -> PP.Projection
mkProjection' expr = PP.Projection {PP.source = expr, PP.alias = Nothing}

mkReset                               :: PRe.Reset                              
mkReset                               = PB.defaultValue
mkRow                                 :: PR.Row                                
mkRow                                 = PB.defaultValue
mkScalarOctets                        :: PSO.Octets                      
mkScalarOctets                        = PB.defaultValue
{- String  -}
mkScalarString                        :: PSS.String                      
mkScalarString                        = PB.defaultValue

scalarString :: String -> PSS.String
scalarString x = PB.defaultValue {PSS.value = PBH.pack x}

mkScalarType                          :: PST.Type                        
mkScalarType                          = PB.defaultValue
{-
  Scalar :: data Type = V_SINT | V_UINT | V_NULL | V_OCTETS | V_DOUBLE | V_FLOAT | V_BOOL | V_STRING
-}
mkScalar                              :: PS.Scalar                             
mkScalar                              = PB.defaultValue

-- | Make a Null.
mkNullScalar :: PS.Scalar
mkNullScalar = PB.defaultValue {PS.type' = PST.V_NULL}

-- | Make an Scalar instance and Retrieve a value from Scalar.
class Scalarable x where
  -- | Make an Scalar instance.
  scalar         :: x         -> PS.Scalar
  -- | Retrieve a value from Scalar safely.
  getScalarVal   :: PS.Scalar -> Maybe x
  -- | Retrieve a value from Scalar, an exception maybe occurs.
  getScalarVal'  :: (MonadIO m, MonadThrow m) => PS.Scalar -> m x
  -- | Retrieve a value from Scalar unsafely.
  getScalarVal'' :: PS.Scalar -> x
  getScalarVal'' = M.fromJust . getScalarVal

-- | internal use only (TODO hiding)
_getScalarVal' :: (MonadIO m, MonadThrow m) 
  => PST.Type 
  -> (PS.Scalar -> Maybe a) 
  -> (a -> b) 
  -> String 
  -> PS.Scalar 
  -> m b
_getScalarVal' t func trans info scl = 
    if PS.type' scl == t then
      case func scl of 
        Just x  -> return $ trans x 
        Nothing -> throwM $ XProtocolException $ info ++ " value is Nothing" 
    else
      throwM $ XProtocolException $ F.concat ["type of scalar value is not ", info, ", actually ", show $ PS.type' scl] 

instance Scalarable Int      where 
  scalar x                    = PB.defaultValue {PS.type' = PST.V_SINT  , PS.v_signed_int   = Just $ fromIntegral x}
  getScalarVal  PS.Scalar{..} = fromIntegral <$> v_signed_int
  getScalarVal' x = _getScalarVal' PST.V_SINT PS.v_signed_int fromIntegral "V_SINT" x

instance Scalarable I.Int64  where 
  scalar x = PB.defaultValue {PS.type' = PST.V_SINT  , PS.v_signed_int   = Just x}
  getScalarVal PS.Scalar{..} = v_signed_int
  getScalarVal' x = _getScalarVal' PST.V_SINT PS.v_signed_int id "V_SINT" x

instance Scalarable W.Word8  where 
  scalar x = PB.defaultValue {PS.type' = PST.V_UINT  , PS.v_unsigned_int = Just $ fromIntegral x}
  getScalarVal PS.Scalar{..} = fromIntegral <$> v_unsigned_int
  getScalarVal' x = _getScalarVal' PST.V_UINT PS.v_unsigned_int fromIntegral "V_UINT" x

instance Scalarable W.Word64 where
  scalar x = PB.defaultValue {PS.type' = PST.V_UINT  , PS.v_unsigned_int = Just x}
  getScalarVal PS.Scalar{..} = v_unsigned_int
  getScalarVal' x = _getScalarVal' PST.V_UINT PS.v_unsigned_int id "V_UINT" x

instance Scalarable Double   where
  scalar x = PB.defaultValue {PS.type' = PST.V_DOUBLE, PS.v_double       = Just x}
  getScalarVal PS.Scalar{..} = v_double
  getScalarVal' x = _getScalarVal' PST.V_DOUBLE PS.v_double id "V_DOUBLE" x

instance Scalarable Float    where
  scalar x = PB.defaultValue {PS.type' = PST.V_FLOAT , PS.v_float        = Just x}
  getScalarVal PS.Scalar{..} = v_float
  getScalarVal' x = _getScalarVal' PST.V_FLOAT PS.v_float id "V_FLOAT" x

instance Scalarable Bool     where
  scalar x = PB.defaultValue {PS.type' = PST.V_BOOL  , PS.v_bool         = Just x}
  getScalarVal PS.Scalar{..} = v_bool
  getScalarVal' x = _getScalarVal' PST.V_BOOL PS.v_bool id "V_BOOL" x

instance Scalarable String   where
  scalar x = PB.defaultValue {PS.type' = PST.V_STRING, PS.v_string       = Just $ scalarString x}
  getScalarVal PS.Scalar{..} = (T.unpack . TE.decodeUtf8 . BL.toStrict . PSS.value) <$> v_string
  getScalarVal' x = _getScalarVal' PST.V_STRING PS.v_string (T.unpack . TE.decodeUtf8 . BL.toStrict . PSS.value) "V_STRING" x

instance Scalarable T.Text   where
  scalar x = PB.defaultValue {PS.type' = PST.V_STRING, PS.v_string       = Just $ scalarString (T.unpack x)}
  getScalarVal PS.Scalar{..} = (TE.decodeUtf8 . BL.toStrict . PSS.value) <$> v_string
  getScalarVal' x = _getScalarVal' PST.V_STRING PS.v_string (TE.decodeUtf8 . BL.toStrict . PSS.value) "V_STRING" x

-- | Nothing to be converted to a Null Scalar.
instance (Scalarable a) => Scalarable (Maybe a) where
  scalar (Just x) = scalar x 
  scalar Nothing  = mkNullScalar 
  getScalarVal    = getScalarVal  --  TODO test. 
  getScalarVal'   = getScalarVal' --  TODO test.

mkServerMessagesType                  :: PSMT.Type                
mkServerMessagesType                  = PB.defaultValue
mkServerMessages                      :: PSM.ServerMessages                     
mkServerMessages                      = PB.defaultValue
mkSessionStateChangedParameter        :: PSSCP.Parameter      
mkSessionStateChangedParameter        = PB.defaultValue
mkSessionStateChanged                 :: PSSC.SessionStateChanged                
mkSessionStateChanged                 = PB.defaultValue
mkSessionVariableChanged              :: PSVC.SessionVariableChanged             
mkSessionVariableChanged              = PB.defaultValue
{-
StmtExecute
-}
mkStmtExecute :: String -> String -> [PA.Any] -> Bool -> PSE.StmtExecute
mkStmtExecute ns sql args meta = PB.defaultValue
    `setNamespace`       ns
    `setStmt`            sql
    `setStmtArgs`        args
    `setCompactMetadata` meta

mkStmtExecuteSql :: String -> [PA.Any] -> PSE.StmtExecute
mkStmtExecuteSql sql args = PB.defaultValue
    `setStmt`            sql
    `setStmtArgs`        args

mkStmtExecuteX :: String -> [PA.Any] -> Bool -> PSE.StmtExecute
mkStmtExecuteX sql args meta = PB.defaultValue
    `setNamespace`       "mysqlx"
    `setStmt`            sql
    `setStmtArgs`        args
    `setCompactMetadata` meta

mkStmtExecuteX' :: String -> [PA.Any] -> PSE.StmtExecute
mkStmtExecuteX' sql args = mkStmtExecuteX sql args False

setNamespace :: PSE.StmtExecute -> String -> PSE.StmtExecute
setNamespace stmt ns = stmt {PSE.namespace = Just $ PBH.uFromString ns} 

setStmt :: PSE.StmtExecute -> String -> PSE.StmtExecute
setStmt stmt sql = stmt {PSE.stmt = (BL.fromStrict . TE.encodeUtf8 . T.pack) sql} 

setStmtArgs :: PSE.StmtExecute -> [PA.Any]-> PSE.StmtExecute
setStmtArgs stmt args = stmt {PSE.args = Seq.fromList args} 

setStmtArg :: PSE.StmtExecute -> PA.Any-> PSE.StmtExecute
setStmtArg stmt arg = stmt {PSE.args = arg <| PSE.args stmt} 

setCompactMetadata :: PSE.StmtExecute -> Bool -> PSE.StmtExecute
setCompactMetadata stmt meta = stmt {PSE.compact_metadata = Just meta} 


mkStmtExecuteOk                       :: PSEO.StmtExecuteOk                      
mkStmtExecuteOk                       = PB.defaultValue
mkUpdate                              :: PU.Update                             
mkUpdate                              = PB.defaultValue
mkUpdateOperationUpdateType           :: PUOUT.UpdateType         
mkUpdateOperationUpdateType           = PB.defaultValue

{- UpdateOperation -}
-- | Make an UpdateOperation instance.
mkUpdateOperation :: 
     PUOUT.UpdateType       -- ^ type
  -> PCI.ColumnIdentifier   -- ^ identifier
  -> PEx.Expr               -- ^ Expr
  -> PUO.UpdateOperation
mkUpdateOperation ut iden ex = PUO.UpdateOperation {PUO.source = iden, PUO.operation = ut, PUO.value = Just ex} 

mkUpdateOperationSet         = mkUpdateOperation PUOUT.SET             -- table only
mkUpdateOperationItemRemove  = mkUpdateOperation PUOUT.ITEM_REMOVE 
mkUpdateOperationItemSet     = mkUpdateOperation PUOUT.ITEM_SET        -- add
mkUpdateOperationItemReplace = mkUpdateOperation PUOUT.ITEM_REPLACE    
mkUpdateOperationItemMerge   = mkUpdateOperation PUOUT.ITEM_MERGE  
mkUpdateOperationArrayInsert = mkUpdateOperation PUOUT.ARRAY_INSERT  
mkUpdateOperationArrayAppend = mkUpdateOperation PUOUT.ARRAY_APPEND

-- | Make an update item.
class (Exprable a) => UpdateOperatable a where 

  updateSet                 :: String -> a -> PUO.UpdateOperation
  updateSet         ident a  = mkUpdateOperationSet         (columnIdentifierDocumentPahtItem [mkDocumentPathItem ident]) (expr a)

  updateItemRemove          :: String -> a -> PUO.UpdateOperation
  updateItemRemove  ident a  = mkUpdateOperationItemRemove  (columnIdentifierDocumentPahtItem [mkDocumentPathItem ident]) (expr a)
  
  updateItemSet             :: String -> a -> PUO.UpdateOperation
  updateItemSet     ident a  = mkUpdateOperationItemSet     (columnIdentifierDocumentPahtItem [mkDocumentPathItem ident]) (expr a)   

  updateItemReplace         :: String -> a -> PUO.UpdateOperation
  updateItemReplace ident a  = mkUpdateOperationItemReplace (columnIdentifierDocumentPahtItem [mkDocumentPathItem ident]) (expr a)

  updateItemMerge           :: String -> a -> PUO.UpdateOperation
  updateItemMerge   ident a = mkUpdateOperationItemMerge    (columnIdentifierDocumentPahtItem [mkDocumentPathItem ident]) (expr a)

instance UpdateOperatable Int      
instance UpdateOperatable Int64
instance UpdateOperatable Word8
instance UpdateOperatable Word64
instance UpdateOperatable Double
instance UpdateOperatable Float
instance UpdateOperatable Bool
instance UpdateOperatable String
instance UpdateOperatable Text

-- | Make an update array insert operation.
updateArrayInsert :: String -> PAR.Array -> PUO.UpdateOperation
updateArrayInsert ident arr = mkUpdateOperationArrayInsert (columnIdentifierDocumentPahtItem [mkDocumentPathItem ident]) (expr arr)

-- | Make an update array append operation.
updateArrayAppend :: String -> PAR.Array -> PUO.UpdateOperation
updateArrayAppend ident arr = mkUpdateOperationArrayAppend (columnIdentifierDocumentPahtItem [mkDocumentPathItem ident]) (expr arr)

mkViewAlgorithm                       :: PVA.ViewAlgorithm                      
mkViewAlgorithm                       = PB.defaultValue
mkViewCheckOption                     :: PVCO.ViewCheckOption                    
mkViewCheckOption                     = PB.defaultValue
mkViewSqlSecurity                     :: PVSS.ViewSqlSecurity                    
mkViewSqlSecurity                     = PB.defaultValue
mkWarningLevel                        :: PWL.Level                      
mkWarningLevel                        = PB.defaultValue
mkWarning                             :: PW.Warning                            
mkWarning                             = PB.defaultValue

--     CURRENT_SCHEMA = 1;
getCurrentSchema :: (MonadIO m, MonadThrow m, Scalarable a)  => PSSC.SessionStateChanged -> m a
getCurrentSchema = getSessionStateChangedVal PSSCP.CURRENT_SCHEMA "CURRENT_SCHEMA"

--     ACCOUNT_EXPIRED = 2;
getAccountExpired :: (MonadIO m, MonadThrow m, Scalarable a)  => PSSC.SessionStateChanged -> m a
getAccountExpired = getSessionStateChangedVal PSSCP.ACCOUNT_EXPIRED "ACCOUNT_EXPIRED"

--     GENERATED_INSERT_ID = 3;
getGeneratedInsertId :: (MonadIO m, MonadThrow m, Scalarable a)  => PSSC.SessionStateChanged -> m a
getGeneratedInsertId = getSessionStateChangedVal PSSCP.GENERATED_INSERT_ID "GENERATED_INSERT_ID"

--     ROWS_AFFECTED = 4;
getRowsAffected :: (MonadIO m, MonadThrow m)  => PSSC.SessionStateChanged -> m W.Word64 
getRowsAffected = getSessionStateChangedVal PSSCP.ROWS_AFFECTED "ROWS_AFFECTED"

--     ROWS_FOUND = 5;
getRowsFound :: (MonadIO m, MonadThrow m, Scalarable a)  => PSSC.SessionStateChanged -> m a
getRowsFound = getSessionStateChangedVal PSSCP.ROWS_FOUND "ROWS_FOUND"

--     ROWS_MATCHED = 6;
getRowsMatched :: (MonadIO m, MonadThrow m, Scalarable a)  => PSSC.SessionStateChanged -> m a
getRowsMatched = getSessionStateChangedVal PSSCP.ROWS_MATCHED "ROWS_MATCHED"

--     TRX_COMMITTED = 7;
getTrxCommited :: (MonadIO m, MonadThrow m, Scalarable a)  => PSSC.SessionStateChanged -> m a
getTrxCommited = getSessionStateChangedVal PSSCP.TRX_COMMITTED "TRX_COMMITTED"

--     TRX_ROLLEDBACK = 9;
getTrxRolldback :: (MonadIO m, MonadThrow m, Scalarable a)  => PSSC.SessionStateChanged -> m a
getTrxRolldback = getSessionStateChangedVal PSSCP.TRX_ROLLEDBACK "TRX_ROLLEDBACK"

--     PRODUCED_MESSAGE = 10;
getProducedMessage :: (MonadIO m, MonadThrow m, Scalarable a)  => PSSC.SessionStateChanged -> m a
getProducedMessage = getSessionStateChangedVal PSSCP.PRODUCED_MESSAGE "PRODUCED_MESSAGE"

--     CLIENT_ID_ASSIGNED = 11;
getClientId :: (MonadIO m, MonadThrow m) => PSSC.SessionStateChanged -> m W.Word64
getClientId = getSessionStateChangedVal PSSCP.CLIENT_ID_ASSIGNED "CLIENT_ID_ASSIGNED"

getSessionStateChangedVal :: (MonadIO m, MonadThrow m, Scalarable a) => PSSCP.Parameter -> String -> PSSC.SessionStateChanged -> m a
getSessionStateChangedVal p info ssc = do
  debug ssc
  if PSSC.param ssc == p then 
    case PSSC.value ssc of 
      Just s  -> getScalarVal' s 
      Nothing -> throwM $ XProtocolException $ "param is " ++ info ++ ", but Nothing"
  else
    throwM $ XProtocolException $ "param is not " ++ info ++ ", but " ++ (show $ PSSC.param ssc) 

-- | Server message NO : ok = 0
s_ok                                   =  0 :: Int
-- | Server message NO : error = 1
s_error                                =  1 :: Int
-- | Server message NO : conn_capabilities = 2
s_conn_capabilities                    =  2 :: Int
-- | Server message NO : sess_authenticate_continue = 3
s_sess_authenticate_continue           =  3 :: Int
-- | Server message NO : sess_authenticate_ok =4
s_sess_authenticate_ok                 =  4 :: Int
-- | Server message NO : notice = 11
s_notice                               = 11 :: Int
-- | Server message NO : resultset_column_meta_data = 12
s_resultset_column_meta_data           = 12 :: Int
-- | Server message NO : resultset_row = 13
s_resultset_row                        = 13 :: Int
-- | Server message NO : resultset_fetch_done = 14
s_resultset_fetch_done                 = 14 :: Int
-- | Server message NO : resultset_fetch_suspended = 15
s_resultset_fetch_suspended            = 15 :: Int
-- | Server message NO : resultset_fetch_done_more_resultsets = 16
s_resultset_fetch_done_more_resultsets = 16 :: Int
-- | Server message NO : resultset_fetch_done_more_out_params = 17
s_sql_stmt_execute_ok                  = 17 :: Int
-- | Server message NO : resultset_fetch_done_more_out_params = 18 
s_resultset_fetch_done_more_out_params = 18 :: Int
 
getClientMsgTypeNo ::  (Typeable msg, Show msg) => msg -> Int
getClientMsgTypeNo msg = 
  case found of
    Nothing -> Prelude.error $ "getClientMsgTpeNo faliure, msg=" ++ show msg
    Just (a,b,c) -> a
  where found = Data.List.find (\(a, b, c) -> c == typeOf msg) clientMessageMap 

-- | Mapping between a message type number and an object.
clientMessageMap :: [(Int, PCMT.Type, TypeRep)]
clientMessageMap =
   [
      ( 1, PCMT.CON_CAPABILITIES_GET,       typeOf (undefined :: PCG.CapabilitiesGet) ),
      ( 2, PCMT.CON_CAPABILITIES_SET,       typeOf (undefined :: PCS.CapabilitiesSet) ),
      ( 3, PCMT.CON_CLOSE,                  typeOf (undefined :: PC.Close) ),
      ( 4, PCMT.SESS_AUTHENTICATE_START,    typeOf (undefined :: PAS.AuthenticateStart) ),
      ( 5, PCMT.SESS_AUTHENTICATE_CONTINUE, typeOf (undefined :: PAC.AuthenticateContinue) ),
      ( 6, PCMT.SESS_RESET,                 typeOf (undefined :: PRe.Reset) ),
      ( 7, PCMT.SESS_CLOSE,                 typeOf (undefined :: PC.Close) ),
      (12, PCMT.SQL_STMT_EXECUTE,           typeOf (undefined :: PSE.StmtExecute ) ), 
      (17, PCMT.CRUD_FIND,                  typeOf (undefined :: PF.Find) ),
      (18, PCMT.CRUD_INSERT,                typeOf (undefined :: PI.Insert) ),
      (19, PCMT.CRUD_UPDATE,                typeOf (undefined :: PU.Update) ),
      (20, PCMT.CRUD_DELETE,                typeOf (undefined :: PD.Delete) ),
      (24, PCMT.EXPECT_OPEN,                typeOf (undefined :: POp.Open) ),
      (25, PCMT.EXPECT_CLOSE,               typeOf (undefined :: PC.Close) ),
      (30, PCMT.CRUD_CREATE_VIEW,           typeOf (undefined :: PCV.CreateView) ),
      (31, PCMT.CRUD_MODIFY_VIEW,           typeOf (undefined :: PMV.ModifyView) ),
      (32, PCMT.CRUD_DROP_VIEW,             typeOf (undefined :: PDV.DropView) )
   ]


--
-- for debug purpose 
--
-- | Serialize an object to a file.
writeObj :: (PBW.Wire a, PBR.ReflectDescriptor a) => FilePath -> a -> IO ()
writeObj path obj = BL.writeFile path $ PBW.messagePut obj

-- | Deserialize a file to an object.
--
-- Example
--
--  >>> let x = readObj "memo/dump_java_insert_prepared_type_timestamp.bin" :: IO StmtExecute
--  >>> import Text.Pretty.Simple
--  >>> :t pPrint
-- pPrint :: (MonadIO m, Show a) => a -> m ()
--  >>> x >>= pPrint
-- StmtExecute
--     { namespace = Just "sql"
--     , stmt = "insert into data_type_timestamp values (?);"
--     , args = fromList
--         [ Any
--             { type' = SCALAR
--             , scalar = Just
--                 ( Scalar
--                     { type' = V_STRING
--                     , v_signed_int = Nothing
--                     , v_unsigned_int = Nothing
--                     , v_octets = Nothing
--                     , v_double = Nothing
--                     , v_float = Nothing
--                     , v_bool = Nothing
--                     , v_string = Just
--                         ( String
--                             { value = "2017-09-17T12:34:56.0"
--                             , collation = Nothing
--                             }
--                         )
--                     }
--                 )
--             , obj = Nothing
--             , array = Nothing
--             }
--         ]
--     , compact_metadata = Just False
--     }
--  >>>
readObj :: (MonadIO m, MonadThrow m, PBW.Wire a, PBR.ReflectDescriptor a, PBT.TextMsg a, Typeable a) => FilePath -> m a
readObj path = do
  bin <- liftIO  $ B.readFile path 
  obj <- getMessage bin
  return obj

