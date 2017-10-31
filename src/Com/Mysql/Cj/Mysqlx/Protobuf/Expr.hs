{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Com.Mysql.Cj.Mysqlx.Protobuf.Expr (Expr(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ArrayExpr as Com.Mysql.Cj.Mysqlx.Protobuf (ArrayExpr)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnIdentifier as Com.Mysql.Cj.Mysqlx.Protobuf (ColumnIdentifier)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Expr.Type as Com.Mysql.Cj.Mysqlx.Protobuf.Expr (Type)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.FunctionCall as Com.Mysql.Cj.Mysqlx.Protobuf (FunctionCall)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ObjectExpr as Com.Mysql.Cj.Mysqlx.Protobuf (ObjectExpr)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Operator as Com.Mysql.Cj.Mysqlx.Protobuf (Operator)
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Scalar as Com.Mysql.Cj.Mysqlx.Protobuf (Scalar)

data Expr = Expr{type' :: !(Com.Mysql.Cj.Mysqlx.Protobuf.Expr.Type),
                 identifier :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ColumnIdentifier), variable :: !(P'.Maybe P'.Utf8),
                 literal :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Scalar),
                 function_call :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.FunctionCall),
                 operator :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.Operator), position :: !(P'.Maybe P'.Word32),
                 object :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ObjectExpr),
                 array :: !(P'.Maybe Com.Mysql.Cj.Mysqlx.Protobuf.ArrayExpr)}
          deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Expr where
  mergeAppend (Expr x'1 x'2 x'3 x'4 x'5 x'6 x'7 x'8 x'9) (Expr y'1 y'2 y'3 y'4 y'5 y'6 y'7 y'8 y'9)
   = Expr (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2) (P'.mergeAppend x'3 y'3) (P'.mergeAppend x'4 y'4)
      (P'.mergeAppend x'5 y'5)
      (P'.mergeAppend x'6 y'6)
      (P'.mergeAppend x'7 y'7)
      (P'.mergeAppend x'8 y'8)
      (P'.mergeAppend x'9 y'9)

instance P'.Default Expr where
  defaultValue
   = Expr P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue
      P'.defaultValue
      P'.defaultValue

instance P'.Wire Expr where
  wireSize ft' self'@(Expr x'1 x'2 x'3 x'4 x'5 x'6 x'7 x'8 x'9)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size
         = (P'.wireSizeReq 1 14 x'1 + P'.wireSizeOpt 1 11 x'2 + P'.wireSizeOpt 1 9 x'3 + P'.wireSizeOpt 1 11 x'4 +
             P'.wireSizeOpt 1 11 x'5
             + P'.wireSizeOpt 1 11 x'6
             + P'.wireSizeOpt 1 13 x'7
             + P'.wireSizeOpt 1 11 x'8
             + P'.wireSizeOpt 1 11 x'9)
  wirePut ft' self'@(Expr x'1 x'2 x'3 x'4 x'5 x'6 x'7 x'8 x'9)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutReq 8 14 x'1
             P'.wirePutOpt 18 11 x'2
             P'.wirePutOpt 26 9 x'3
             P'.wirePutOpt 34 11 x'4
             P'.wirePutOpt 42 11 x'5
             P'.wirePutOpt 50 11 x'6
             P'.wirePutOpt 56 13 x'7
             P'.wirePutOpt 66 11 x'8
             P'.wirePutOpt 74 11 x'9
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             8 -> Prelude'.fmap (\ !new'Field -> old'Self{type' = new'Field}) (P'.wireGet 14)
             18 -> Prelude'.fmap
                    (\ !new'Field -> old'Self{identifier = P'.mergeAppend (identifier old'Self) (Prelude'.Just new'Field)})
                    (P'.wireGet 11)
             26 -> Prelude'.fmap (\ !new'Field -> old'Self{variable = Prelude'.Just new'Field}) (P'.wireGet 9)
             34 -> Prelude'.fmap (\ !new'Field -> old'Self{literal = P'.mergeAppend (literal old'Self) (Prelude'.Just new'Field)})
                    (P'.wireGet 11)
             42 -> Prelude'.fmap
                    (\ !new'Field -> old'Self{function_call = P'.mergeAppend (function_call old'Self) (Prelude'.Just new'Field)})
                    (P'.wireGet 11)
             50 -> Prelude'.fmap (\ !new'Field -> old'Self{operator = P'.mergeAppend (operator old'Self) (Prelude'.Just new'Field)})
                    (P'.wireGet 11)
             56 -> Prelude'.fmap (\ !new'Field -> old'Self{position = Prelude'.Just new'Field}) (P'.wireGet 13)
             66 -> Prelude'.fmap (\ !new'Field -> old'Self{object = P'.mergeAppend (object old'Self) (Prelude'.Just new'Field)})
                    (P'.wireGet 11)
             74 -> Prelude'.fmap (\ !new'Field -> old'Self{array = P'.mergeAppend (array old'Self) (Prelude'.Just new'Field)})
                    (P'.wireGet 11)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> Expr) Expr where
  getVal m' f' = f' m'

instance P'.GPB Expr

instance P'.ReflectDescriptor Expr where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList [8]) (P'.fromDistinctAscList [8, 18, 26, 34, 42, 50, 56, 66, 74])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Mysqlx.Expr.Expr\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Expr\"}, descFilePath = [\"Com\",\"Mysql\",\"Cj\",\"Mysqlx\",\"Protobuf\",\"Expr.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.type\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"type'\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expr.Expr.Type\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName = MName \"Type\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.identifier\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"identifier\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expr.ColumnIdentifier\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ColumnIdentifier\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.variable\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"variable\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 26}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.literal\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"literal\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 4}, wireTag = WireTag {getWireTag = 34}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Datatypes.Scalar\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Scalar\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.function_call\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"function_call\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 5}, wireTag = WireTag {getWireTag = 42}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expr.FunctionCall\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"FunctionCall\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.operator\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"operator\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 6}, wireTag = WireTag {getWireTag = 50}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expr.Operator\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"Operator\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.position\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"position\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 7}, wireTag = WireTag {getWireTag = 56}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 13}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.object\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"object\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 8}, wireTag = WireTag {getWireTag = 66}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expr.ObjectExpr\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ObjectExpr\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Mysqlx.Expr.Expr.array\", haskellPrefix' = [], parentModule' = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\",MName \"Expr\"], baseName' = FName \"array\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 9}, wireTag = WireTag {getWireTag = 74}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Mysqlx.Expr.ArrayExpr\", haskellPrefix = [], parentModule = [MName \"Com\",MName \"Mysql\",MName \"Cj\",MName \"Mysqlx\",MName \"Protobuf\"], baseName = MName \"ArrayExpr\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType Expr where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg Expr where
  textPut msg
   = do
       P'.tellT "type" (type' msg)
       P'.tellT "identifier" (identifier msg)
       P'.tellT "variable" (variable msg)
       P'.tellT "literal" (literal msg)
       P'.tellT "function_call" (function_call msg)
       P'.tellT "operator" (operator msg)
       P'.tellT "position" (position msg)
       P'.tellT "object" (object msg)
       P'.tellT "array" (array msg)
  textGet
   = do
       mods <- P'.sepEndBy
                (P'.choice
                  [parse'type', parse'identifier, parse'variable, parse'literal, parse'function_call, parse'operator,
                   parse'position, parse'object, parse'array])
                P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'type'
         = P'.try
            (do
               v <- P'.getT "type"
               Prelude'.return (\ o -> o{type' = v}))
        parse'identifier
         = P'.try
            (do
               v <- P'.getT "identifier"
               Prelude'.return (\ o -> o{identifier = v}))
        parse'variable
         = P'.try
            (do
               v <- P'.getT "variable"
               Prelude'.return (\ o -> o{variable = v}))
        parse'literal
         = P'.try
            (do
               v <- P'.getT "literal"
               Prelude'.return (\ o -> o{literal = v}))
        parse'function_call
         = P'.try
            (do
               v <- P'.getT "function_call"
               Prelude'.return (\ o -> o{function_call = v}))
        parse'operator
         = P'.try
            (do
               v <- P'.getT "operator"
               Prelude'.return (\ o -> o{operator = v}))
        parse'position
         = P'.try
            (do
               v <- P'.getT "position"
               Prelude'.return (\ o -> o{position = v}))
        parse'object
         = P'.try
            (do
               v <- P'.getT "object"
               Prelude'.return (\ o -> o{object = v}))
        parse'array
         = P'.try
            (do
               v <- P'.getT "array"
               Prelude'.return (\ o -> o{array = v}))