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

module DataBase.MySQLX.CRUD
  (
  
    -- * Setting a field to a CRUD record
   setCollection       -- collection
  ,setCollection'
  ,setDataModel        -- data_model
  ,setDocumentModel    -- DOCUMENT 
  ,setTableModel       -- TABLE
  ,setFields           -- projection
  ,setColumns          -- projection
  ,setCriteria         -- criteria
  ,setTypedRow         -- row
  ,setTypedRow'        -- row
  ,setArgs             -- args
  ,setLimit            -- limit
  ,setOrder            -- order
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

import qualified Data.Word                      as W
import qualified Data.Sequence                  as Seq
import Data.Typeable          (TypeRep, Typeable, typeRep, typeOf)

-- generated library
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
  -- | Set Table Model 
  setTableModel    :: a -> a
  setTableModel    a = a `setDataModel` PDM.TABLE
instance HasDataModel PF.Find   where setDataModel a dataModel = a {PF.data_model = Just dataModel }
instance HasDataModel PU.Update where setDataModel a dataModel = a {PU.data_model = Just dataModel }
instance HasDataModel PI.Insert where setDataModel a dataModel = a {PI.data_model = Just dataModel }
instance HasDataModel PD.Delete where setDataModel a dataModel = a {PD.data_model = Just dataModel }

-- | CRUD operations which need a Criteria. 
class HasCriteria a where
  -- | Set Criteria record 
  setCriteria :: a -> PEx.Expr -> a
instance HasCriteria PF.Find   where setCriteria a criteria = a {PF.criteria = Just criteria } 
instance HasCriteria PU.Update where setCriteria a criteria = a {PU.criteria = Just criteria } 
instance HasCriteria PD.Delete where setCriteria a criteria = a {PD.criteria = Just criteria } 

-- | CRUD operations which need Args.
class HasArgs a where
  -- | Set Args record 
  setArgs :: a -> [PS.Scalar] -> a
instance HasArgs PF.Find   where setArgs a arg = a {PF.args = Seq.fromList arg } 
instance HasArgs PU.Update where setArgs a arg = a {PU.args = Seq.fromList arg } 
instance HasArgs PI.Insert where setArgs a arg = a {PI.args = Seq.fromList arg } 
instance HasArgs PD.Delete where setArgs a arg = a {PD.args = Seq.fromList arg } 

class HasLimit a where
  -- | CRUD operations which need a Limit 
  setLimit :: a -> PL.Limit -> a 
instance HasLimit PF.Find   where setLimit a lmt = a {PF.limit = Just lmt } 
instance HasLimit PU.Update where setLimit a lmt = a {PU.limit = Just lmt } 
instance HasLimit PD.Delete where setLimit a lmt = a {PD.limit = Just lmt } 

class HasOrder a where
  -- | CRUD operations which need a Order.
  setOrder :: a -> [PO.Order] -> a 
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

-- | put grouping field to a Find record. (This is like a group by clause of SQL)
setGrouping :: PF.Find -> [PEx.Expr] -> PF.Find
setGrouping find group = find {PF.grouping = Seq.fromList group } 

-- | put grouping_criteria to a Find record. (This is like a having clause of SQL)
setGroupingCriteria :: PF.Find -> PEx.Expr -> PF.Find
setGroupingCriteria find criteria = find {PF.grouping_criteria = Just criteria } 

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
  debug fd
  runReaderT (writeMessageR fd) nodeSess
  ret <- runReaderT readMessagesR nodeSess
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

