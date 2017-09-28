{- |
module      : DataBase.MySQLX.JSON
description : JSON 
copyright   : (c) naoto ogawa, 2017
license     : mit 
maintainer  :  
stability   : experimental
portability : 
-}

{-# LANGUAGE ScopedTypeVariables #-}

module DataBase.MySQLX.JSON 
  (
    expr
  , insertJSONUUID  
  ) where

-- general, standard library
import Control.Applicative         (Applicative,pure,(<$>),(<*>))
import Control.Monad               (mzero,(=<<),(<=<),(>=>))
import qualified Data.Aeson        as JSON 
import qualified Data.Aeson.Parser as JSONP 
import qualified Data.Aeson.Types  as JSONT
import qualified Data.HashMap.Lazy as MapL
import Data.Scientific
import qualified Data.Text         as T
import           Data.UUID
import           Data.UUID.V4
import qualified Data.Vector       as V
-- generated library

-- protocol buffer library

-- my library
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.Util

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- | Value belongs to Exprable class.
instance Exprable JSONT.Value where 
  expr (JSON.Object v) = expr $ map (\x -> mkObjectFieldExpr (T.unpack x) (expr $ v MapL.! x) ) (MapL.keys v) 
  expr (JSON.Array  v) = expr $ mkArray $ expr <$> (V.foldl (\acc x -> x:acc) [] v) 
  expr (JSON.Number v) = case floatingOrInteger v of -- TODO
                              -- Left  (f::Float)  -> expr f
                              Left  (f::Double) -> expr f
                              Right (i::Int)    -> expr i
  expr (JSON.String v) = expr v 
  expr (JSON.Bool   v) = expr v 
  expr (JSON.Null    ) = mkNullExpr

-- | JSON Object modification parser. 
-- see http://d.hatena.ne.jp/melpon/20111026/1319602571
applyObject :: (JSON.Object -> JSON.Object) -> JSONT.Value -> JSONT.Parser JSONT.Value
applyObject f value = JSON.Object . f <$> JSON.parseJSON value

-- | Insert function for JSON
insertJSON :: String -> String -> JSONT.Value -> JSONT.Parser JSONT.Value
insertJSON key val = applyObject (MapL.insert (T.pack key) (JSONT.String $ T.pack val))

-- | Lookup function for JSON
lookupJSON :: String -> (JSONT.Value -> JSONT.Parser String)
lookupJSON key = JSONT.parseJSON >=> (JSONT..: T.pack key)

-- | Check if JSON has a key.
hasKeyJSON :: String -> JSONT.Value -> Bool
hasKeyJSON key jval = 
  case JSONT.parseMaybe (lookupJSON key) jval of
    Just _  -> True
    Nothing -> False

-- | Add uuid to JSON Value.
--
--  >>> data Person' = Person' {name :: T.Text , age  :: Int } deriving (Generic, Show)
--  >>> let xx =  toJSON $  Person' "ogawa" 1
--  >>> insertJSONUUID xx
--  Object (fromList [("_id",String "2d70949acf834abdaa6429962a256196"),("age",Number 1.0),("name",String "ogawa")])
-- 
--  >>> data Person = Person { _id  :: String , name :: T.Text , age  :: Int } deriving (Generic, Show)
--  >>> let yy=  toJSON $  Person "***uuid***" "ogawa" 1
--  >>> insertJSONUUID yy
--  Object (fromList [("_id",String "***uuid***"),("age",Number 1.0),("name",String "ogawa")])
--  
insertJSONUUID :: JSONT.Value -> IO JSONT.Value
insertJSONUUID jval = 
  case hasKeyJSON "_id" jval of
    True   -> return jval
    False  -> do 
      uuid <- nextRandom
      return $ forceResult $ JSONT.parse (insertJSON "_id" $ removeUnderscores $ toString uuid) jval 
  where
    forceResult (JSONT.Success v) = v

