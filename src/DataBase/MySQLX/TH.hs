{-# LANGUAGE TemplateHaskell,  TypeSynonymInstances, FlexibleInstances, DefaultSignatures, DeriveLift  #-}

module DataBase.MySQLX.TH where

import Language.Haskell.TH.Syntax
import Language.Haskell.TH

import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Sequence as Seq

import DataBase.MySQLX.Statement 


class (ColumnValuable a) => RecordValueable a where 
  getValFromSeq :: Int -> Seq.Seq BL.ByteString -> a
  getValFromSeq idx seq = toColVal $ Seq.index seq idx

instance RecordValueable Int
instance RecordValueable String

-- $(getRow ''MyRecord) myParam
retrieveRow :: Name -> Q Exp
retrieveRow nm = do
   info <- reify nm 
   TyConI (DataD _ _ _ _ [RecC nm xs] _) <- reify nm 
   retrieveRow' nm (length xs) 

retrieveRow' :: Name -> Int -> Q Exp
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


