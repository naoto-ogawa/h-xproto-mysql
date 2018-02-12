{- |
module      : DataBase.MySQLX.ResultSet
description : SQL Operations
copyright   : (c) naoto ogawa, 2017
license     : MIT 
maintainer  :  
stability   : experimental
portability : 
-}
{-# LANGUAGE RecordWildCards      #-}

module DataBase.MySQLX.ResultSet
  (
    ResultSetMetaData
   ,Row
   ,ResultSet
   ,getSizeRs
   ,getColumnsNameTypeRs 
   ,getColumnTypeRs
   ,getColumnTypesRs
   ,getColumnTypeByNameRs
   ,getColumnTypeByNameRs'
   ,getColumnNamesRs
   ,getColumnNamesTextRs
   ,getColumnNameTextRs
   ,getColumnIdxByNameRs
   ,getColumnIdxByNameRs'
   ,getOriginalNameRs
   ,getTableRs
   ,getOriginalTableRS
   ,getSchemaRs
   ,getCatalogRs
   ,getColumnCollationRs
   ,getColumnFractionalDigitsRs
   ,getColumnLengthRs
   ,getColumnFlagsRs
   ,getColumnContentTypeRs
  ) where

-- general, standard library
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Foldable        as Fld
import qualified Data.Sequence        as Seq
import qualified Data.Text            as T
import qualified Data.Maybe           as M
import qualified Data.Word            as W

-- generated library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType           as PCMDFT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD

-- protocolbuffers

-- my library
import DataBase.MySQLX.Model            as XM
import DataBase.MySQLX.Util

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- | Row Type
type Row = Seq.Seq BL.ByteString 

-- | ResultSet Type
type ResultSet = [Row]

-- | Metadata Type
type ResultSetMetaData = Seq.Seq PCMD.ColumnMetaData 

{-
data ColumnMetaData = ColumnMetaData{
      type'             :: !(Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType)
    , name              :: !(P'.Maybe P'.ByteString)
    , original_name     :: !(P'.Maybe P'.ByteString)
    , table             :: !(P'.Maybe P'.ByteString)
    , original_table    :: !(P'.Maybe P'.ByteString)
    , schema            :: !(P'.Maybe P'.ByteString)
    , catalog           :: !(P'.Maybe P'.ByteString)
    , collation         :: !(P'.Maybe P'.Word64)
    , fractional_digits :: !(P'.Maybe P'.Word32)
    , length            :: !(P'.Maybe P'.Word32)
    , flags             :: !(P'.Maybe P'.Word32)
    , content_type      :: !(P'.Maybe P'.Word32)
}

data FieldType = SINT | UINT | DOUBLE | FLOAT | BYTES | TIME | DATETIME | SET | ENUM | BIT | DECIMAL
 
-}

-- | Get the size of columns.
getSizeRs :: ResultSetMetaData -> Int
getSizeRs = Seq.length

{- name and type -}
getColumnsNameTypeRs :: ResultSetMetaData -> [(T.Text, PCMDFT.FieldType)]
getColumnsNameTypeRs meta = Fld.toList $ fmap (\colmeta -> (getColumnName colmeta, getColumnType colmeta)) meta

{- type -}
getColumnTypeRs :: ResultSetMetaData -> Int -> PCMDFT.FieldType 
getColumnTypeRs meta idx = XM.getColumnType $ Seq.index meta idx 

getColumnTypesRs :: ResultSetMetaData -> Seq.Seq PCMDFT.FieldType 
getColumnTypesRs meta = foldr (\x acc -> acc Seq.|> XM.getColumnType x) Seq.empty meta

getColumnTypeByNameRs :: String -> ResultSetMetaData -> Maybe PCMDFT.FieldType 
getColumnTypeByNameRs name meta = if Seq.null cols then Nothing else Just $ PCMD.type' $ Seq.index cols 0
  where cols      = Seq.filter (\colmeta -> eqlCMDName colmeta name) meta 

getColumnTypeByNameRs' :: String -> ResultSetMetaData -> PCMDFT.FieldType 
getColumnTypeByNameRs' name meta = M.fromJust $ getColumnTypeByNameRs name meta

{- name -}
getColumnNamesRs :: ResultSetMetaData -> Seq.Seq (Maybe BL.ByteString)
getColumnNamesRs meta = foldr (\PCMD.ColumnMetaData{..} acc -> acc Seq.|> name) Seq.empty meta

getColumnNamesTextRs :: ResultSetMetaData -> Seq.Seq T.Text 
getColumnNamesTextRs meta = foldr (\x acc -> acc Seq.|> getColumnName x) Seq.empty meta

getColumnNameTextRs :: ResultSetMetaData -> Int -> T.Text
getColumnNameTextRs meta idx = getColumnName $ Seq.index meta idx 

getColumnIdxByNameRs :: ResultSetMetaData -> String -> Maybe Int
getColumnIdxByNameRs meta name = safeHead [i | (colmeta, i) <- zip (Fld.toList meta) [0..], eqlCMDName colmeta name] 

getColumnIdxByNameRs' :: ResultSetMetaData -> String -> Int
getColumnIdxByNameRs' meta name = M.fromJust $ getColumnIdxByNameRs meta name 

{- original_name -}
getOriginalNameRs :: ResultSetMetaData -> Int -> T.Text
getOriginalNameRs meta idx = getColumnOriginalName $ Seq.index meta idx 

{- table -}
getTableRs :: ResultSetMetaData -> Int -> T.Text
getTableRs  meta idx = getColumnTable $ Seq.index meta idx 

{- original_table -}
getOriginalTableRS :: ResultSetMetaData -> Int -> T.Text
getOriginalTableRS meta idx = getColumnOriginalTable $ Seq.index meta idx 

{- schema -}
getSchemaRs :: ResultSetMetaData -> Int -> T.Text
getSchemaRs meta idx = getColumnSchema  $ Seq.index meta idx 

{- catalog -}
getCatalogRs :: ResultSetMetaData -> Int -> T.Text
getCatalogRs meta idx = getColumnCatalog $ Seq.index meta idx 

{- collation -}
getColumnCollationRs :: ResultSetMetaData -> Int -> W.Word64 
getColumnCollationRs meta idx = getColumnCollation $ Seq.index meta idx 

{- fractional_digits -}
getColumnFractionalDigitsRs :: ResultSetMetaData -> Int -> W.Word32 
getColumnFractionalDigitsRs meta idx = getColumnFractionalDigits $ Seq.index meta idx 

{- length -}
getColumnLengthRs :: ResultSetMetaData -> Int -> W.Word32 
getColumnLengthRs meta idx = getColumnLength $ Seq.index meta idx 

{- flags -}
getColumnFlagsRs :: ResultSetMetaData -> Int -> W.Word32 
getColumnFlagsRs meta idx = getColumnFlags $ Seq.index meta idx 

{- content_type -}
getColumnContentTypeRs :: ResultSetMetaData -> Int -> W.Word32 
getColumnContentTypeRs meta idx = getColumnContentType $ Seq.index meta idx 




