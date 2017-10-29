{- |
module      : DataBase.MySQLX.TH
description : utility functions using template haskell 
copyright   : (c) naoto ogawa, 2017
license     : MIT 
maintainer  :  
stability   : experimental
portability : 
-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE DefaultSignatures    #-}

module DataBase.MySQLX.TH 
  (
   retrieveRow
  ,getValFromSeq
  ) where

-- general, standard library
import Language.Haskell.TH.Syntax
import Language.Haskell.TH

import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Sequence        as Seq

-- my library
import DataBase.MySQLX.Statement 

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------
class (ColumnValuable a) => RecordValueable a where 
  -- | get a value of a expected type from a row.
  getValFromSeq :: Int -> Seq.Seq BL.ByteString -> a
  getValFromSeq idx seq = toColVal $ Seq.index seq idx

instance RecordValueable Int
instance RecordValueable String

-- | Generate a function which converts a row of resultset (Seq ByteString) to a record (which a user defined).
--
-- > $(getRow ''MyRecord) (x :: Seq ByteString) 
--
-- the above code generates the below code:
--
-- > MyRecord (getVal $ Seq.index seq 0) (getVal $ Seq.index seq 1) (getVal $ Seq.index seq 2)
--

-- | Generate a mapping function from ResultSet to a row data by a record.
retrieveRow :: Name -> Q Exp
retrieveRow nm = do
   info <- reify nm 
   -- we need a data constructor and parameters.
   TyConI (DataD _ _ _ _ [RecC nm xs] _) <- reify nm  
   retrieveRow' nm (length xs) 

-- | Generate auated expression for making a record. 
--
-- example
-- > generated_function :: Seq ByteStringString -> MyRecord
-- > generated_function seq = MyRecord (getValFromSeq $ Seq.index seq 0) 
--                                     (getValFromSeq $ Seq.index seq 1) 
--                                     (getValFromSeq $ Seq.index seq 2)
--
retrieveRow' :: Name   -- ^ data construcotr
             -> Int    -- ^ number of parameters
             -> Q Exp  -- ^ generated function
retrieveRow' nm cnt = fncQ nm 
  where 
    fv      :: Name
    fv = mkName "fv"
    mkParam :: Integer -> Exp
    mkParam n = (AppE (AppE (VarE $ mkName "getValFromSeq") (LitE (IntegerL n))) (VarE fv))
    params  :: Integer -> [Exp]
    params n = foldr (\x acc -> (mkParam x) : acc) [] [0..n]
    ppp     :: [Exp]
    ppp = params $ fromIntegral $ cnt - 1
    fncQ    :: Name -> Q Exp
    fncQ nm = return $ LamE [VarP fv] $ foldr (\x acc -> AppE acc x) (AppE (ConE nm) (head ppp)) (reverse $ tail ppp)


