{- |
module      : DataBase.MySQLX.Util 
description : utilties 
copyright   : (c) naoto ogawa, 2017
license     : mit 
maintainer  :  
stability   : experimental
portability : 
-}

module DataBase.MySQLX.Util 
  (
   safeHead
  ,toHex
  ,toHex'
  ,getIntFromLE
  ,putMessageLengthLE
  ,putMessageType
  ,insertUUID
  ,insertUUIDIO
  ,getPasswordHash
  ,removeUnderscores
  ,isJust
  ,preUtf8
  ,suffUtf8
  ,mapUtf8
  ,s2bs
  ,s2bs'
  ,bs2s
  ,bs2s'
  ,byte2Int
  ,uppercase
  ,debug 
  ,pPrint_
  ) where

import Control.Monad.IO.Class

import qualified Crypto.Hash              as H
import qualified Data.ByteString.Char8    as C8
import qualified Data.Binary              as BIN
import           Data.Binary.Get
import           Data.Binary.Put
import qualified Data.ByteArray           as DBA
import qualified Data.ByteString          as B
import           Data.ByteString.Builder
import           Data.ByteString.Conversion.To as Conv
import qualified Data.ByteString.Internal as BI
import qualified Data.ByteString.Unsafe   as BU
import qualified Data.ByteString.Lazy     as BL 
import qualified Data.Foldable            as F 
import qualified Data.Int                 as I
import qualified Data.Text                as T
import qualified Data.Text.Lazy           as TL
import qualified Data.Text.Lazy.IO        as TLIO 
import           Data.Text.Encoding       as E
import           Data.Text.Lazy.Encoding  as EL


import qualified Data.Word                as W
import           Data.UUID                hiding (null)
import           Data.UUID.V4

import           Text.Pretty.Simple                        as X
import           Text.Pretty.Simple.Internal.ExprParser    as X
import           Text.Pretty.Simple.Internal.Expr          as X
import           Text.Pretty.Simple.Internal.ExprToOutput  as X
import           Text.Pretty.Simple.Internal.Output        as X
import           Text.Pretty.Simple.Internal.OutputPrinter as X
import Data.Bits

import Foreign.Ptr
import Foreign.Storable

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- | Safehead
safeHead = \xs -> if Prelude.null xs then Nothing else Just $ head xs

-- | get a Int32 from little endian ByteString
getIntFromLE :: B.ByteString -> I.Int32 
getIntFromLE x = runGet getInt32le $ BL.fromStrict x

-- | put a Int8 into ByteString
putMessageType :: I.Int8 -> BL.ByteString
putMessageType x = runPut (putInt8 x)

-- | put a Int32 into ByteString as a little endian. 
putMessageLengthLE :: I.Int32 -> BL.ByteString
putMessageLengthLE x = runPut (putInt32le x)

-- -----------------------------------------------------------------------------
-- Password
-- -----------------------------------------------------------------------------

-- | make a hashed password.
getPasswordHash :: (ToByteString a, ToByteString b) 
                => a              -- ^ salt
                -> b              -- ^ password
                -> BL.ByteString  -- ^ a hashed password
getPasswordHash salt pw = _getPasswordHash' (toLazyByteString $ builder salt) (toLazyByteString $ builder pw)

_getPasswordHash' :: BL.ByteString -> BL.ByteString -> BL.ByteString
_getPasswordHash' = (BL.fromStrict . ) . (_change2Params BL.toStrict _getPasswordHash) 

_getPasswordHash :: BI.ByteString -> BI.ByteString -> BI.ByteString
_getPasswordHash salt pw = 
  DBA.xor s1 s3
  where
    s1 :: H.Digest H.SHA1
    s1 = _sha1 pw
    s2 :: H.Digest H.SHA1
    s2 = _sha1 $ DBA.pack $ DBA.unpack s1
    s3 :: H.Digest H.SHA1
    s3 = _sha1 $ DBA.append (DBA.pack $ BI.unpackBytes salt) (DBA.pack $ DBA.unpack s2)

_sha1 :: C8.ByteString -> H.Digest H.SHA1
_sha1 = H.hash

_change2Params :: (a -> b) -> (b -> b -> c) -> (a -> a -> c)
_change2Params f g = \x y -> g (f x) (f y) 

-- -----------------------------------------------------------------------------
-- UUID 
-- -----------------------------------------------------------------------------

-- | insert uuid into JSON string.
insertUUID :: String -- ^ JSON string
           -> String -- ^ uuid string 
           -> String -- ^ JSON string with UUID ({ "_id" : ****uuid***, ... })
insertUUID json uuid = 
  a ++ [head b] ++ "\"_id\" : \"" ++ uuid ++ "\", " ++ (tail b)
  where
    (a,b) = break (\x -> x == '{') json

-- | insert uuid into JSON string.
insertUUIDIO :: String -> IO String
insertUUIDIO json = do
  uuid <- nextRandom
  return $ insertUUID json $ removeUnderscores $ toString uuid

-- | remove all unserscores in a String  
removeUnderscores :: String -> String
removeUnderscores x = foldr (\x a -> if x == '-' then a else x : a) [] x

--
_maxLen :: Int
_maxLen = maxBound `quot` 2

_hexDig :: W.Word8 -> W.Word8
_hexDig d
    | d < 10    = d + 48
    | otherwise = d + 87

-- -----------------------------------------------------------------------------
-- Hex 
-- -----------------------------------------------------------------------------

-- | make a hex representation.
toHex' :: BL.ByteString -> BL.ByteString
toHex' = BL.fromStrict . toHex . BL.toStrict 

-- | make a hex representation.
-- https://stackoverflow.com/questions/10099921/efficiently-turn-a-bytestring-into-a-hex-representation?answertab=active#tab-top
toHex :: BI.ByteString -> BI.ByteString
toHex bs
    | len > _maxLen = error "too long to convert"
    | otherwise    = BI.unsafeCreate nl (go 0)
      where
        len = B.length bs
        nl  = 2*len
        go i p
            | i == len  = return ()
            | otherwise = case BU.unsafeIndex bs i of
                            w -> do poke p (_hexDig $ w `shiftR` 4)
                                    poke (p `plusPtr` 1) (_hexDig $ w .&. 0xF)
                                    go (i+1) (p `plusPtr` 2)

-- -----------------------------------------------------------------------------
-- Utf8 
-- -----------------------------------------------------------------------------
-- | Append string before Utf8.
preUtf8 :: String -> PB.Utf8 -> PB.Utf8
preUtf8 prefix bsUtf8 = PB.Utf8 $ (Conv.toByteString prefix) `BL.append` (PB.utf8 bsUtf8)

-- | Append string after Utf8.
suffUtf8 :: PB.Utf8 -> String -> PB.Utf8
suffUtf8 bsUtf8 suffix = PB.Utf8 $ (PB.utf8 bsUtf8) `BL.append` (Conv.toByteString suffix)

-- | fmap-like function for Utf8
mapUtf8 :: (BL.ByteString -> BL.ByteString) -> PB.Utf8 -> PB.Utf8 
mapUtf8 f bsUtf8 = PB.Utf8 $ f (PB.utf8 bsUtf8) 

-- -----------------------------------------------------------------------------
-- Numeric  ByteString  
-- -----------------------------------------------------------------------------
byte2Int :: B.ByteString -> Int
byte2Int = fromIntegral . B.head

-- -----------------------------------------------------------------------------
-- Maybe 
-- -----------------------------------------------------------------------------
isJust :: Maybe a -> Bool
isJust x = case x of
  Just y  -> True
  Nothing -> False

-- -----------------------------------------------------------------------------
-- String conversion 
-- -----------------------------------------------------------------------------
s2bs :: String -> B.ByteString
s2bs = E.encodeUtf8 . T.pack 

bs2s :: B.ByteString -> String
bs2s = T.unpack . E.decodeUtf8 

s2bs' :: String -> BL.ByteString
s2bs' = EL.encodeUtf8 . TL.pack 

bs2s' :: BL.ByteString -> String
bs2s' = TL.unpack . EL.decodeUtf8 

-- http://bluebones.net/2007/01/replace-in-haskell/
replace :: Eq a => [a] -> [a] -> [a] -> [a]
replace [] _ _ = []
replace s find repl =
    if take (length find) s == find
        then repl ++ (replace (drop (length find) s) find repl)
        else [head s] ++ (replace (tail s) find repl)

-- https://stackoverflow.com/a/20479476
uppercase :: B.ByteString -> B.ByteString
uppercase x = C8.pack $ map (\c -> if c >= 'a' && c <= 'z' then toEnum (fromEnum c - 32) else c) $ C8.unpack x
-- -----------------------------------------------------------------------------
-- Debug 
-- -----------------------------------------------------------------------------

-- | debug message IO
debug :: (MonadIO m, Show a) => a -> m ()
debug = liftIO . print
-- debug = return $ return () --liftIO . print


-- -----------------------------------------------------------------------------
-- Debug 
-- Copy and Paset from Text.Pretty.Simple 
-- -----------------------------------------------------------------------------

pPrint_ :: (MonadIO m, Show a) => a -> m ()
pPrint_ = pPrintOpt_ defaultOutputOptionsDarkBg

pPrintOpt_ :: (MonadIO m, Show a) => OutputOptions -> a -> m ()
pPrintOpt_ outputOptions = liftIO . TLIO.putStrLn . pShowOpt_ outputOptions

pShowOpt_ :: Show a => OutputOptions -> a -> TL.Text
pShowOpt_ outputOptions = pStringOpt_ outputOptions . show

pStringOpt_ :: OutputOptions -> String -> TL.Text
pStringOpt_ outputOptions string =
  case expressionParse string of
    Left _ -> TL.pack string
    Right expressions ->
        render outputOptions . F.toList $ expressionsToOutputs $ removeNothing (not . isNothing) expressions
                                                                      -- add ~~~~~~~~~~~~~~~~  
removeNothing :: (Expr -> Bool) -> [Expr] -> [Expr]
removeNothing f []     = []
removeNothing f (x:xs) = 
  case x of
    (Other _)            -> if isNothing x then removeNothing f xs else x : removeNothing f xs
    (StringLit _)                   -> x                                  : removeNothing f xs
    (Brackets (CommaSeparated exs)) -> (Brackets $ doCommaSeparated exs)  : removeNothing f xs
    (Braces   (CommaSeparated exs)) -> (Braces   $ doCommaSeparated exs)  : removeNothing f xs
    (Parens   (CommaSeparated exs)) -> (Parens   $ doCommaSeparated exs)  : removeNothing f xs
  where removeNul = filter (not . null)
        recursive = foldr (\x acc -> removeNothing f x : acc) []
        doCommaSeparated exs = CommaSeparated . removeNul $ recursive exs

isNothingStr :: String -> Bool
isNothingStr str = length xs == 3 && last xs == "Nothing"
  where xs = words str

isNothing :: Expr -> Bool
isNothing (Other str) = isNothingStr str
isNothing _ = False 

