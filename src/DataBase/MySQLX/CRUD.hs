
module DataBase.MySQLX.CRUD
  (
    setCollection
   ,setDataModel
   ,setTypedRow 
   ,setCriteria
   ,setOperation
   ,setFields
   ,setGrouping
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

--
--
--
{-

                  find update insert delete
collection         *    *      *      *
data_model         *    *      *      *        option
projection         *1   -      *2     -        list      *1   *2 : Column
criteria           *    *      -      *        option
row                -    -      *      -        list     TypedRow
args               *    *      *      *        list
limit              *    *      -      *        option 
order              *    *      -      *        list
grouping           *    -      -      -        list
grouping_criteria  *    -      -      -        option
operation          -    *      -      -        list

class HasCollection a where setCollection :: a -> Collection -> a
class HasDataModel a where setDataModel :: a -> DataModel -> a
class HasCriteria a where setCriteria :: a -> Expr -> a
class HasArgs a where setArgs :: a -> [Scalar] -> a
class HasLimit a where setLimit :: a -> Limit -> a
class HasOrder a where setOrder :: a -> [DOR.Order] -> a

-}

class HasCollection a where 
  -- | CRUD operations which need a Collection.
  setCollection :: a -> PCll.Collection -> a
instance HasCollection PF.Find   where setCollection a coll = a {PF.collection = coll } 
instance HasCollection PU.Update where setCollection a coll = a {PU.collection = coll } 
instance HasCollection PI.Insert where setCollection a coll = a {PI.collection = coll } 
instance HasCollection PD.Delete where setCollection a coll = a {PD.collection = coll } 

class HasDataModel a where
  -- | CRUD operations which need a DataModel.
  setDataModel :: a -> PDM.DataModel -> a 
instance HasDataModel PF.Find   where setDataModel a dataModel = a {PF.data_model = Just dataModel }
instance HasDataModel PU.Update where setDataModel a dataModel = a {PU.data_model = Just dataModel }
instance HasDataModel PI.Insert where setDataModel a dataModel = a {PI.data_model = Just dataModel }
instance HasDataModel PD.Delete where setDataModel a dataModel = a {PD.data_model = Just dataModel }

class HasCriteria a where
  -- | CRUD operations which need a Criteria. 
  setCriteria :: a -> PEx.Expr -> a
instance HasCriteria PF.Find   where setCriteria a criteria = a {PF.criteria = Just criteria } 
instance HasCriteria PU.Update where setCriteria a criteria = a {PU.criteria = Just criteria } 
instance HasCriteria PD.Delete where setCriteria a criteria = a {PD.criteria = Just criteria } 

class HasArgs a where
  -- | CRUD operations which need Args.
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
mkInsert :: PCll.Collection -> PDM.DataModel -> [PCol.Column] -> [PITR.TypedRow] -> [PS.Scalar] -> PI.Insert
mkInsert col model projs rows args = PB.defaultValue 
    `setCollection` col 
    `setDataModel`  model 
    `setColumns`    projs 
    `setTypedRow`   rows
    `setArgs`       args 

setColumns :: PI.Insert -> [PCol.Column] -> PI.Insert
setColumns inst clms = inst {PI.projection = Seq.fromList clms} 

setTypedRow :: PI.Insert -> [PITR.TypedRow] -> PI.Insert
setTypedRow inst rows = inst {PI.row = Seq.fromList rows} 

-- | Delete
mkDelete :: PCll.Collection -> PDM.DataModel -> PEx.Expr -> [PS.Scalar] -> PL.Limit -> [PO.Order] -> PD.Delete
mkDelete col model criteria args lmt orders = PB.defaultValue
    `setCollection` col 
    `setDataModel`  model 
    `setCriteria`   criteria  -- Expr
    `setArgs`       args      -- [Scalar] 
    `setLimit`      lmt       -- Limit
    `setOrder`      orders    -- Order

-- | Update
mkUpdate :: PCll.Collection -> PDM.DataModel -> PEx.Expr -> [PS.Scalar] -> PL.Limit -> [PO.Order] -> [PUO.UpdateOperation] -> PU.Update
mkUpdate col model criteria args lmt orders upOpes = PB.defaultValue
    `setCollection` col 
    `setDataModel`  model 
    `setCriteria`   criteria 
    `setArgs`       args 
    `setLimit`      lmt 
    `setOrder`      orders 
    `setOperation`  upOpes    -- UpdateOperation

setOperation:: PU.Update -> [PUO.UpdateOperation] -> PU.Update
setOperation up upOpe = up {PU.operation = Seq.fromList upOpe} 

-- | Find
mkFind :: PCll.Collection  -> PDM.DataModel -> [PP.Projection] -> PEx.Expr -> [PS.Scalar] -> PL.Limit -> [PO.Order] -> [PEx.Expr] -> PEx.Expr -> PF.Find -- TODO 集計部分の実装
mkFind col model projs criteria args lmt orders grouping gCriteria = PB.defaultValue 
    `setCollection` col 
    `setDataModel`  model 
    `setFields`     projs     -- Seq   Projection
    `setCriteria`   criteria  -- Maybe Expr
    `setArgs`       args      -- Seq   Scalar
    `setLimit`      lmt       -- Maybe Limit
    `setOrder`      orders    -- Seq   Order
    `setGrouping`   grouping  -- Seq   Expr

setFields :: PF.Find -> [PP.Projection] -> PF.Find
setFields find proj = find {PF.projection = Seq.fromList proj }

setGrouping :: PF.Find -> [PEx.Expr] -> PF.Find
setGrouping find group = find {PF.grouping = Seq.fromList group } 

-- TODO 以下の４つの関数はclass化する。
-- | Insert Reader
insertR :: (MonadIO m, MonadThrow m) => PI.Insert-> ReaderT NodeSession m () 
insertR = writeMessageR

-- | Delete Reader
deleteR :: (MonadIO m, MonadThrow m) => PD.Delete -> ReaderT NodeSession m () 
deleteR = writeMessageR

-- | Update Reader
updateR :: (MonadIO m, MonadThrow m) => PU.Update -> ReaderT NodeSession m () 
updateR =  writeMessageR

-- | Find Reader
findR :: (MonadIO m, MonadThrow m) => PF.Find -> ReaderT NodeSession m () 
findR = writeMessageR 

-- TODO delete, update, insertの共通化
delete ::  (MonadIO m, MonadThrow m) => PD.Delete -> NodeSession -> m W.Word64
delete del nodeSess = do
  runReaderT (deleteR del) nodeSess
  ret@(x:xs) <- runReaderT readMessagesT nodeSess                           -- [(Int, B.ByteString)]
  if fst x == s_error then do
    msg <- getError $ snd x
    throwM $ XProtocolError msg
  else do 
    frm <- (getFrame . snd ) $ head $ filter (\(t, b) -> t == s_notice) ret  -- Frame
    ssc <- getPayloadSessionStateChanged frm
    getRowsAffected ssc

update ::  (MonadIO m, MonadThrow m) => PU.Update -> NodeSession -> m W.Word64 
update del nodeSess = do
  runReaderT (updateR del) nodeSess
  ret@(x:xs) <- runReaderT readMessagesT nodeSess                           -- [(Int, B.ByteString)]
  if fst x == s_error then do
    msg <- getError $ snd x
    throwM $ XProtocolError msg
  else do 
    frm <- (getFrame . snd ) $ head $ filter (\(t, b) -> t == s_notice) ret  -- Frame
    ssc <- getPayloadSessionStateChanged frm
    getRowsAffected ssc

insert ::  (MonadIO m, MonadThrow m) => PI.Insert -> NodeSession -> m W.Word64 
insert ins nodeSess = do
  runReaderT (insertR ins) nodeSess
  ret@(x:xs) <- runReaderT readMessagesT nodeSess                           -- [(Int, B.ByteString)]
  if fst x == s_error then do
    msg <- getError $ snd x
    throwM $ XProtocolError msg
  else do 
    frm <- (getFrame . snd ) $ head $ filter (\(t, b) -> t == s_notice) ret  -- Frame
    ssc <- getPayloadSessionStateChanged frm
    getRowsAffected ssc

find :: (MonadIO m, MonadThrow m) => PF.Find -> NodeSession -> m (Seq.Seq PCMD.ColumnMetaData, [Seq.Seq BL.ByteString])  -- TODO selectと共通化, エラーハンドリング 
find fd nodeSess = do
  debug fd
  runReaderT (findR fd) nodeSess
  ret <- runReaderT readMessagesT nodeSess
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

