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
  ,debug 
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
import           Data.ByteString.Conversion.To
import qualified Data.ByteString.Internal as BI
import qualified Data.ByteString.Unsafe   as BU
import qualified Data.ByteString.Lazy     as BL 
import qualified Data.Int                 as I
import qualified Data.Word                as W
import           Data.UUID
import           Data.UUID.V4

import Data.Bits
import Foreign.Ptr
import Foreign.Storable

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
-- Debug 
-- -----------------------------------------------------------------------------

-- | debug message IO
debug :: (MonadIO m, Show a) => a -> m ()
debug = liftIO . print
-- debug = return $ return () --liftIO . print


