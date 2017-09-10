module DataBase.MySQLX.Util where

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

getIntFromLE :: B.ByteString -> I.Int32 
getIntFromLE x = runGet getInt32le $ BL.fromStrict x

putMessageType :: I.Int8 -> BL.ByteString
putMessageType x = runPut (putInt8 x)

putMessageLengthLE :: I.Int32 -> BL.ByteString
putMessageLengthLE x = runPut (putInt32le x)


getPasswordHash'' :: (ToByteString a, ToByteString b) => a -> b -> BL.ByteString
getPasswordHash'' salt pw = getPasswordHash' (toLazyByteString $ builder salt) (toLazyByteString $ builder pw)

getPasswordHash' :: BL.ByteString -> BL.ByteString -> BL.ByteString
-- getPasswordHash' x y = BL.fromStrict $ (change2Params BL.toStrict getPasswordHash) x y
getPasswordHash' = (BL.fromStrict . ) . (change2Params BL.toStrict getPasswordHash) 

getPasswordHash :: BI.ByteString -> BI.ByteString -> BI.ByteString
getPasswordHash salt pw = 
  DBA.xor s1 s3
  where
    s1 :: H.Digest H.SHA1
    s1 = sha1 pw
    s2 :: H.Digest H.SHA1
    s2 = sha1 $ DBA.pack $ DBA.unpack s1
    s3 :: H.Digest H.SHA1
    s3 = sha1 $ DBA.append (DBA.pack $ BI.unpackBytes salt) (DBA.pack $ DBA.unpack s2)

sha1 :: C8.ByteString -> H.Digest H.SHA1
sha1 = H.hash

change2Params :: (a -> b) -> (b -> b -> c) -> (a -> a -> c)
change2Params f g = \x y -> g (f x) (f y) 

insertUUID :: String -> String -> String
insertUUID json uuid = 
  a ++ [head b] ++ "\"_id\" : \"" ++ uuid ++ "\", " ++ (tail b)
  where
    (a,b) = break (\x -> x == '{') json

insertUUIDIO :: String -> IO String
insertUUIDIO json = do
  uuid <- nextRandom
  return $ insertUUID json $ removeUnderscore $ toString uuid
  where
    removeUnderscore x = foldr (\x a -> if x == '-' then a else x : a) [] x

--
-- https://stackoverflow.com/questions/10099921/efficiently-turn-a-bytestring-into-a-hex-representation?answertab=active#tab-top
-- 
maxLen :: Int
maxLen = maxBound `quot` 2

hexDig :: W.Word8 -> W.Word8
hexDig d
    | d < 10    = d + 48
    | otherwise = d + 87

toHex' :: BL.ByteString -> BL.ByteString
toHex' = BL.fromStrict . toHex . BL.toStrict 

toHex :: BI.ByteString -> BI.ByteString
toHex bs
    | len > maxLen = error "too long to convert"
    | otherwise    = BI.unsafeCreate nl (go 0)
      where
        len = B.length bs
        nl  = 2*len
        go i p
            | i == len  = return ()
            | otherwise = case BU.unsafeIndex bs i of
                            w -> do poke p (hexDig $ w `shiftR` 4)
                                    poke (p `plusPtr` 1) (hexDig $ w .&. 0xF)
                                    go (i+1) (p `plusPtr` 2)

--
--
--
debug :: (MonadIO m, Show a) => a -> m ()
debug = liftIO . print


