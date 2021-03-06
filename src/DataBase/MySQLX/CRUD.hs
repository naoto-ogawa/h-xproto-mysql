{- |
module      : Database.MySQLX.CRUD 
description : crud interface 
copyright   : (c) naoto ogawa, 2017
license     : MIT 
maintainer  :  
stability   : experimental
portability : 

CRUD interface 
@
                  find update insert delete
collection         *    *      *      *
data_model         *    *      *      *        option
projection         *1   -      *2     -        list     *1 : Fields   *2 : Column
criteria           *    *      -      *        option
row                -    -      *      -        list     TypedRow
args               *    *      *      *        list
limit              *    *      -      *        option 
order              *    *      -      *        list
grouping           *    -      -      -        list
grouping_criteria  *    -      -      -        option
operation          -    *      -      -        list
@
-}

{-# LANGUAGE ConstrainedClassMethods #-}

module DataBase.MySQLX.CRUD
  (
  
    -- * Setting a field to a CRUD record
   setCollection       -- collection
  ,setCollection'
  ,setDataModel        -- data_model
  ,setDocumentModel    -- DOCUMENT 
  ,getDocumentModel    -- DOCUMENT 
  ,setTableModel       -- TABLE
  ,getTableModel       -- TABLE
  ,setFields           -- projection
  ,setFields'          -- projection
  ,setColumns          -- projection
  ,setCriteria         -- criteria
  ,setCriteria'        -- criteria
  ,setCriteriaBind 
  ,setTypedRow         -- row
  ,setTypedRow'        -- row
  ,setArgs             -- args
  ,setLimit            -- limit (Limit)
  ,setLimit'           -- limit (Int)
  ,setLimit''          -- limit (Int, Int)
  ,setOrder            -- order
  ,setOrder'           -- order
  ,setGrouping         -- grouping
  ,setGroupingCriteria -- grouping_criteria
  ,setOperation        -- operation (Only Update)
   -- * Create a CRUD Object 
  ,createInsert
  ,createFind
  ,createUpdate
  ,createDelete
   -- * CRUD Execution 
  ,find
  ,delete
  ,insert
  ,update
  ) where

-- general, standard library
import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM)
import Control.Monad
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Map.Strict      as Map
import qualified Data.Maybe           as Maybe
import qualified Data.Word                      as W
import qualified Data.Sequence                  as Seq
import Data.Typeable          (TypeRep, Typeable, typeRep, typeOf)

-- generated library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Any                                as PA
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData.FieldType           as PCMDFT
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Collection                         as PCll
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Column                             as PCol
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DataModel                          as PDM
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Delete                             as PD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Expr                               as PEx
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find                               as PF
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert.TypedRow                    as PITR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert                             as PI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Limit                              as PL
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Order                              as PO
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Projection                         as PP
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Row                                as PR
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Scalar                             as PS
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Update                             as PU
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.UpdateOperation                    as PUO

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB
import qualified Text.ProtocolBuffers.Basic          as PBB
import qualified Text.ProtocolBuffers.Header         as PBH
import qualified Text.ProtocolBuffers.TextMessage    as PBT
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers.Reflections    as PBR

-- my library
import DataBase.MySQLX.Exception
import DataBase.MySQLX.ExprParser
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession 
import DataBase.MySQLX.Util

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- | CRUD operations which need a Collection 
class HasCollection a where 
  -- | Set collection record 
  setCollection  :: a -> PCll.Collection -> a
  -- | Set a schema and a collection 
  setCollection' :: 
      a         -- ^ CRUD Object
      -> String -- ^ Schema name
      -> String -- ^ Collection name
      -> a      -- ^ CRUD Object
  setCollection' a schema coll = a `setCollection` (mkCollection schema coll) 
instance HasCollection PF.Find   where setCollection a coll = a {PF.collection = coll } 
instance HasCollection PU.Update where setCollection a coll = a {PU.collection = coll } 
instance HasCollection PI.Insert where setCollection a coll = a {PI.collection = coll } 
instance HasCollection PD.Delete where setCollection a coll = a {PD.collection = coll } 

-- | CRUD operations which need a DataModel.
class HasDataModel a where
  -- | Set DataModel record 
  setDataModel :: a -> PDM.DataModel -> a  
  -- | Set Document Model 
  setDocumentModel :: a -> a
  setDocumentModel a = a `setDataModel` PDM.DOCUMENT 
  -- | Get Document Model 
  getDocumentModel :: PBH.Default a => a
  getDocumentModel = PBH.defaultValue `setDataModel` PDM.DOCUMENT 
  -- | Set Table Model 
  setTableModel    :: a -> a
  setTableModel    a = a `setDataModel` PDM.TABLE
  -- | Get Table Model 
  getTableModel    :: PBH.Default a => a
  getTableModel    = PBH.defaultValue `setDataModel` PDM.TABLE
instance HasDataModel PF.Find   where setDataModel a dataModel = a {PF.data_model = Just dataModel }
instance HasDataModel PU.Update where setDataModel a dataModel = a {PU.data_model = Just dataModel }
instance HasDataModel PI.Insert where setDataModel a dataModel = a {PI.data_model = Just dataModel }
instance HasDataModel PD.Delete where setDataModel a dataModel = a {PD.data_model = Just dataModel }

-- | CRUD operations which need a Criteria. 
class HasCriteria a where
  -- | Set Criteria record 
  setCriteria  :: a -> PEx.Expr -> a
  setCriteria' :: a -> String   -> a
  setCriteria' a str = setCriteria a $ parseCriteria' $ s2bs str 
instance HasCriteria PF.Find   where setCriteria a criteria = a {PF.criteria = Just criteria } 
instance HasCriteria PU.Update where setCriteria a criteria = a {PU.criteria = Just criteria } 
instance HasCriteria PD.Delete where setCriteria a criteria = a {PD.criteria = Just criteria } 

-- | CRUD operations which need a Args.
class HasArgs a where
  -- | Set Args record 
  setArgs  :: a -> [PS.Scalar] -> a  -- TODO need to re-order args by a placeholder-order.
instance HasArgs PF.Find   where setArgs a arg = a {PF.args = Seq.fromList arg } 
instance HasArgs PU.Update where setArgs a arg = a {PU.args = Seq.fromList arg } 
instance HasArgs PI.Insert where setArgs a arg = a {PI.args = Seq.fromList arg } 
instance HasArgs PD.Delete where setArgs a arg = a {PD.args = Seq.fromList arg } 

-- | CRUD operations which need both a Criteria and a map of Args
class HasCriteriaBind a where
  setCriteriaBind :: (HasCriteria a, HasArgs a) => a -> (String, BindMap) -> a
  setCriteriaBind a (str, bind) = a `setCriteria` exp `setArgs` map
     where (exp, map) = 
             case parseCriteria $ s2bs str of
               Left  y -> error $ "parseCriteria error " ++ y 
               Right (e, state) -> (e, bindMap2Seq' bind $ bindList state) 
instance HasCriteriaBind PF.Find
instance HasCriteriaBind PU.Update
instance HasCriteriaBind PI.Insert
instance HasCriteriaBind PD.Delete

class HasLimit a where
  -- | CRUD operations which need a Limit 
  setLimit   :: a -> PL.Limit -> a 
  setLimit'  :: a -> Int -> a 
  setLimit'  a num = setLimit  a (mkLimit' num)
  setLimit'' :: a -> Int -> Int -> a 
  setLimit'' a num offset = setLimit a (mkLimit num offset)
instance HasLimit PF.Find   where setLimit a lmt = a {PF.limit = Just lmt } 
instance HasLimit PU.Update where setLimit a lmt = a {PU.limit = Just lmt } 
instance HasLimit PD.Delete where setLimit a lmt = a {PD.limit = Just lmt } 

class HasOrder a where
  -- | CRUD operations which need a Order.
  setOrder  :: a -> [PO.Order] -> a 
  setOrder' :: a -> String -> a 
  setOrder' a str = setOrder a $ parseOrderBy' $ s2bs str 
instance HasOrder PF.Find   where setOrder a ord = a {PF.order = Seq.fromList ord } 
instance HasOrder PU.Update where setOrder a ord = a {PU.order = Seq.fromList ord } 
instance HasOrder PD.Delete where setOrder a ord = a {PD.order = Seq.fromList ord } 

-- | Insert 
createInsert :: PCll.Collection  -- ^ Collection
         -> PDM.DataModel    -- ^ DataModel
         -> [PCol.Column]    -- ^ Column
         -> [PITR.TypedRow]  -- ^ TypedRow
         -> [PS.Scalar]      -- ^ Scalar
         -> PI.Insert        -- ^ Insert Object
createInsert col model projs rows args = PB.defaultValue 
    `setCollection` col 
    `setDataModel`  model 
    `setColumns`    projs 
    `setTypedRow`   rows
    `setArgs`       args 

-- | Set columns to a Insert record.
setColumns :: PI.Insert -> [PCol.Column] -> PI.Insert
setColumns inst clms = inst {PI.projection = Seq.fromList clms} 

-- | Set typed rows to a Insert record.
setTypedRow :: PI.Insert -> [PITR.TypedRow] -> PI.Insert
setTypedRow inst rows = inst {PI.row = Seq.fromList rows} 

-- | Set typed rows to a Insert record from Exprs.
setTypedRow' :: PI.Insert -> [PEx.Expr] -> PI.Insert
setTypedRow' inst exprs = inst {PI.row = Seq.fromList [mkExpr2TypedRow exprs]} 

-- | Delete
createDelete :: PCll.Collection -- ^ Collection 
         -> PDM.DataModel   -- ^ DataModel
         -> PEx.Expr        -- ^ where 
         -> [PS.Scalar]     -- ^ bindings
         -> PL.Limit        -- ^ Limit
         -> [PO.Order]      -- ^ Order
         -> PD.Delete       -- ^ Delete Object
createDelete col model criteria args lmt orders = PB.defaultValue
    `setCollection` col 
    `setDataModel`  model 
    `setCriteria`   criteria  -- Expr
    `setArgs`       args      -- [Scalar] 
    `setLimit`      lmt       -- Limit
    `setOrder`      orders    -- Order

-- | Update
createUpdate :: PCll.Collection -- ^ Collection 
         -> PDM.DataModel   -- ^ DataModel
         -> PEx.Expr        -- ^ where 
         -> [PS.Scalar]     -- ^ bindings
         -> PL.Limit        -- ^ Limit
         -> [PO.Order]      -- ^ Order
         -> [PUO.UpdateOperation] -- ^ UpdateOperation 
         -> PU.Update       -- ^ Update Object
createUpdate col model criteria args lmt orders upOpes = PB.defaultValue
    `setCollection` col 
    `setDataModel`  model 
    `setCriteria`   criteria 
    `setArgs`       args 
    `setLimit`      lmt 
    `setOrder`      orders 
    `setOperation`  upOpes    -- UpdateOperation

-- | Set update operations to a Update record
setOperation:: PU.Update -> [PUO.UpdateOperation] -> PU.Update
setOperation up upOpe = up {PU.operation = Seq.fromList upOpe} 

-- | Find
createFind :: PCll.Collection  -- ^ Collection
       -> PDM.DataModel    -- ^ DataModel
       -> [PP.Projection]  -- ^ Projection
       -> PEx.Expr         -- ^ where 
       -> [PS.Scalar]      -- ^ bindings 
       -> PL.Limit         -- ^ Limit
       -> [PO.Order]       -- ^ Order
       -> [PEx.Expr]       -- ^ group by 
       -> PEx.Expr         -- ^ having 
       -> PF.Find          -- ^ Find Object
createFind col model projs criteria args lmt orders grouping gCriteria = PB.defaultValue 
    `setCollection` col 
    `setDataModel`  model 
    `setFields`     projs     -- Seq   Projection
    `setCriteria`   criteria  -- Maybe Expr
    `setArgs`       args      -- Seq   Scalar
    `setLimit`      lmt       -- Maybe Limit
    `setOrder`      orders    -- Seq   Order
    `setGrouping`   grouping  -- Seq   Expr
    `setGroupingCriteria` gCriteria -- Maybe Expr

-- | put fields to a Find record. (This is like a select clause of SQL)
setFields :: PF.Find -> [PP.Projection] -> PF.Find
setFields find proj = find {PF.projection = Seq.fromList proj }

-- | put fields by String to a Find record. (This is like a select clause of SQL)
setFields' :: PF.Find -> String -> PF.Find
setFields' find proj = find {PF.projection = Seq.fromList $ parseProjection' $ s2bs proj }

-- | put grouping field to a Find record. (This is like a group by clause of SQL)
setGrouping :: PF.Find -> [PEx.Expr] -> PF.Find
setGrouping find group = find {PF.grouping = Seq.fromList group } 

-- | put grouping_criteria to a Find record. (This is like a having clause of SQL)
setGroupingCriteria :: PF.Find -> PEx.Expr -> PF.Find
setGroupingCriteria find criteria = find {PF.grouping_criteria = Just criteria } 

--
-- CRUD functions
--

-- | Common Operation : Insert / Update / Delete 
modify ::  (PBT.TextMsg           msg
           ,PBR.ReflectDescriptor msg
           ,PBW.Wire              msg
           ,Show                  msg
           ,Typeable              msg
           ,MonadIO               m
           ,MonadThrow            m) => msg -> NodeSession -> m W.Word64
modify obj nodeSess = do
  runReaderT (writeMessageR obj) nodeSess
  ret@(x:xs) <- runReaderT readMessagesR nodeSess                           -- [(Int, B.ByteString)]
  if fst x == s_error then do
    msg <- getError $ snd x
    throwM $ XProtocolError msg
  else do 
    frm <- (getFrame . snd ) $ head $ filter (\(t, b) -> t == s_notice) ret  -- Frame
    ssc <- getPayloadSessionStateChanged frm
    getRowsAffected ssc

-- | Delete
delete ::  (MonadIO m, MonadThrow m) => PD.Delete -> NodeSession -> m W.Word64
delete = modify

-- | Update
update ::  (MonadIO m, MonadThrow m) => PU.Update -> NodeSession -> m W.Word64 
update = modify

-- | Insert
insert ::  (MonadIO m, MonadThrow m) => PI.Insert -> NodeSession -> m W.Word64 
insert = modify

-- | Find (Select) 
find :: (MonadIO m, MonadThrow m) => PF.Find -> NodeSession -> m (Seq.Seq PCMD.ColumnMetaData, [Seq.Seq BL.ByteString])  -- TODO selectと共通化, エラーハンドリング 
find fd nodeSess = do
  -- debug fd
  runReaderT (writeMessageR fd) nodeSess
  ret <- runReaderT readMessagesR nodeSess
  -- debug ret
  return $ tupleRfmap ((map PR.field) . join)  -- m (_, [m Row]) -> m (_, [Row]) -> (_, [Seq ByteString])
         $ tupleLfmap ( Seq.fromList  . join)  -- m ([m ColumnMetaData], _) -> m ([ColumnMetaData], _) -> m (Seq ColumnMetaData, _)
         $ foldr f ([], []) ret                -- collect ColumnMetaData and Row, throw away others
  where f = \(t, b) (meta, rows) -> 
              if t == s_resultset_column_meta_data then
                 (getColumnMetaData b : meta , rows           )
              else if t == s_resultset_row then
                 (meta                       , getRow b : rows)
              else
                 (meta                       , rows           ) 
        tupleLfmap f (a,b) = (f a,   b)
        tupleRfmap         = fmap 

--
-- functions for binding
--
-- Map String Scalar -> [String] -> Seq.Seq
type BindMap  = Map.Map String PS.Scalar
type BindList = [String]

emptyBindMap :: BindMap
emptyBindMap = Map.empty

bind :: String -> PS.Scalar -> BindMap -> BindMap
bind key val map = Map.insert key val map

-- ex : bindParams [("a", XM.scalar "aaa"), ("b", XM.scalar 1), ("c", XM.scalar 1.2)]
bindParams :: [(String, PS.Scalar)] -> BindMap
bindParams entries = foldr (\(key, val) accMap -> bind key val accMap) Map.empty entries

{-
bindParams' :: (XM.Scalarable a) => [(String, a)] -> BindMap
bindParams' entries = foldr (\(key, val) accMap -> bind key (XM.scalar val) accMap) Map.empty entries

 >> bindParams' [("a", 1), ("b", True)]

<interactive>:302:20: error:
    • No instance for (Num Bool) arising from the literal ‘1’
    • In the expression: 1
      In the expression: ("a", 1)
      In the first argument of ‘bindParams'’, namely
        ‘[("a", 1), ("b", True)]’
 >>
-}

bindMap2Seq :: BindMap -> BindList -> Seq.Seq PS.Scalar
bindMap2Seq map list = foldl (\acc item -> (Maybe.fromJust $ Map.lookup item map)  Seq.<| acc) Seq.empty list 
-- let map =  bind "c" (XM.scalar (3.0::Double)) $ bind "b" (XM.scalar "b") $ bind "a" (XM.scalar 1) emptyBindMap
-- let list = ["c", "a"] 
-- pPrint $ bind "c" (XM.scalar (3.0::Double)) $ bind "b" (XM.scalar "b") $ bind "a" (XM.scalar 1) emptyBindMap

bindMap2Seq' :: BindMap -> BindList -> [PS.Scalar]
bindMap2Seq' map list = foldl (\acc item -> (Maybe.fromJust $ Map.lookup item map) : acc) [] list 




