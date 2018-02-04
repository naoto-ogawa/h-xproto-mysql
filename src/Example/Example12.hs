module Example.Example12 where

import Data.ByteString.Internal (ByteString(..))
import Foreign.ForeignPtr (withForeignPtr,ForeignPtr)
import Foreign.Ptr (plusPtr, Ptr)
import Foreign.Storable

import Prelude as P

-- general, standard library
import           Data.Bits
import qualified Data.ByteString.Lazy as BL 
import           Data.List.Split.Internals
import           Data.Sequence        as Seq
import           Data.Ratio
import           Data.Word
-- import           Data.BCD.Packed
import           Text.Pretty.Simple
-- protocolbuffers
-- import qualified Text.ProtocolBuffers.WireMessage    as PBW
-- import qualified Text.ProtocolBuffers.Extensions     as PBE
import qualified Text.ProtocolBuffers                as PB

-- protocol buffer library
-- import qualified Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.DataModel                          as PDM
-- import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Delete                             as PD
-- import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Insert                             as PI
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Expr                               as PEx
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Find                               as PF
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.FunctionCall                       as PFC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Limit                              as PL


-- my library
import DataBase.MySQLX.CRUD           as CRUD
import DataBase.MySQLX.Exception
import DataBase.MySQLX.Functions
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement
import DataBase.MySQLX.Util

{-

mysql-sql> create table data_type_decimal (my_decimal decimal(8,3));
Query OK, 0 rows affected (0.05 sec)
mysql-sql> desc data_type_decimal;
+------------+--------------+------+-----+---------+-------+
| Field      | Type         | Null | Key | Default | Extra |
+------------+--------------+------+-----+---------+-------+
| my_decimal | decimal(8,3) | YES  |     | null    |       |
+------------+--------------+------+-----+---------+-------+
1 row in set (0.06 sec)
mysql-sql> select * from data_type_decimal;
+------------+
| my_decimal |
+------------+
|      1.000 |
|  99999.000 |
|  99999.100 |
|  99999.123 |
|   -999.876 |
+------------+

12 -> 0c
13 -> 0d

 | 5f 00 00 00 0c 08 12 12 : 0a 6d 79 5f 64 65 63 69  | _........my_deci
 | 6d 61 6c 1a 0a 6d 79 5f : 64 65 63 69 6d 61 6c 22  | mal..my_decimal"
 | 11 64 61 74 61 5f 74 79 : 70 65 5f 64 65 63 69 6d  | .data_type_decim
 | 61 6c 2a 11 64 61 74 61 : 5f 74 79 70 65 5f 64 65  | al*.data_type_de
 | 63 69 6d 61 6c 32 0f 78 : 5f 70 72 6f 74 6f 63 6f  | cimal2.x_protoco
 | 6c 5f 74 65 73 74 3a 03 : 64 65 66 40 00 48 03 50  | l_test:.def@.H.P
 | 0a 58 00 07 00 00 00 0d : 0a 04 03 10 00 c0 09 00  | .X..............
 | 00 00 0d 0a 06 03 99 99 : 90 00 c0 09 00 00 00 0d  | ................
 | 0a 06 03 99 99 91 00 c0 : 09 00 00 00 0d 0a 06 03  | ................
 | 99 99 91 23 c0 08 00 00 : 00 0d 0a 05 03 99 98 76  | ...#...........v
 | d0 01 00 00 00 0e 0f 00 : 00 00 0b 08 03 10 02 1a  | ................
 | 08 08 04 12 04 08 02 18 : 00 01 00 00 00 11        | ..............

-----------------------
proto| decimal data
<--->|<==============>
0a 04 03 10 00 c0
0a 06 03 99 99 90 00 c0
0a 06 03 99 99 91 00 c0 
0a 06 03 99 99 91 23 c0
0a 05 03 99 98 76 d0  

Example: x04 0x12 0x34 0x01 0xd0 -> -12.3401
0a 05 04 12 34 01 d0

0.34
02 03 4c  --> length (digits) = length( 0 3 4) -> 3 , 3 % 2 = 1 <> 0, so we should ommit the last zero digit.



-}
d0 = fromHexStr "03 10 00 c0"         --     1.000
d1 = fromHexStr "03 99 99 90 00 c0"   -- 99999.000
d2 = fromHexStr "03 99 99 91 00 c0"   -- 99999.100 
d3 = fromHexStr "03 99 99 91 23 c0"   -- 99999.123
d4 = fromHexStr "03 99 98 76 d0"      --  -999.874
d5 = fromHexStr "04 12 34 01 d0"      --   -12.3401
d6 = fromHexStr "02 03 4c"            --     0.34


example12_decimal_1 :: IO ()
example12_decimal_1 = execSimpleTx "x_protocol_test" "root" "root" example12_decimal_1' 

example12_decimal_1' :: NodeSession -> IO ()
example12_decimal_1'  nodeSess = do

  ret <- executeRawSql "select my_decimal from data_type_decimal"  nodeSess
  
  mapM_ (\x -> print $ toHex' (Seq.index x 0) ) ret
  mapM_ (\x -> do
      a <- decodeDecimal $ BL.toStrict (Seq.index x 0) :: IO Float 
      print a
    ) ret
  return ()

-- | Retreive Fractional from ByteString    -- TODO Lazy function
decodeDecimal :: (Fractional a, Num a) => ByteString -> IO a
decodeDecimal (PS fptr off len) = withForeignPtr fptr $ \ptr -> do
  let beg  = ptr `plusPtr` off
      end  = beg `plusPtr` (len - 1)
      bcdF = beg `plusPtr` 1
      bcdT = end `plusPtr` (len - 2) 
  scale <- peek beg :: IO Word8
  debug $ "scale = " ++ (show scale)
  last@(a:b:[]) <- peekHalfBytes end 
  let padding = b == (0 :: Word8)
      sign = if padding then a == 12 else b == 12 -- 12 = c -> plus
  debug $ "sign = " ++ (show sign )
  bcd_ <- decodeBCD bcdF end
  let bcd = if padding then bcd_ else bcd_ ++ [a]
  debug $ bcd
  return $ decodeDouble (map fromIntegral bcd) (fromIntegral scale) sign 

decodeDouble :: (Fractional a) => [a] -> Int -> Bool -> a -- TODO throw exception
decodeDouble num frac sign = (sumtimes num base) * (if sign then 1 else -1)
   where
      len = P.length num
      power = [(len - frac - 1), (len - frac - 2) .. (-frac) ]
      base  = P.map (\x -> 10^^x) power 

decodeRatio :: (Integral a) => [a] -> Int -> Bool -> Ratio a -- TODO throw exception
decodeRatio num frac sign = (((sumtimes num base) % head base')) * (if sign then 1 else -1)
   where
      len = P.length num
      (x1,x2) = P.splitAt (len-frac) num 
      base  = bases len 
      base' = bases (P.length x2) 

bases xs = P.foldr (\x acc -> P.head acc * 10 : acc) [1] [2..xs]

-- | fusing zipWith (*) and sum
-- https://qiita.com/nobsun/items/37d6cc2505af0a3a252f
sumtimes :: (Num a) => [a] -> [a] -> a
sumtimes = foldr fuser (const 0)
  where
    fuser x k []     = 0
    fuser x k (y:ys) = (x * y) + k ys

-- | split Word8 to two 4 bits of Word8
peekHalfBytes :: Ptr Word8 -> IO [Word8]
peekHalfBytes ptr = do
  w8 <- peek ptr
  return [shiftR w8 4, (.&.) w8 15] -- 15 = 1111 (bits)

-- https://en.wikipedia.org/wiki/Binary-coded_decimal
decodeBCD :: Ptr Word8 -> Ptr b -> IO [Word8]
decodeBCD from to = do 
  xs@(a:b) <- peekHalfBytes from
  let next = from `plusPtr` 1
  if next == to 
    then return xs
    else do 
      ys <- decodeBCD next to
      return $ xs ++ ys 

-- | fromHexStr "0a 05 04 12 34 01 d0"
fromHexStr :: String -> BL.ByteString
fromHexStr = fromHexStrList . words

-- | fromHexStr' "0a0504123401d0"
fromHexStr' :: String -> BL.ByteString
fromHexStr' = fromHexStrList . (chunksOf 2)

-- | fromHexStrList [["0a], [05], [04], [12], [34], [01], [d0]]"
fromHexStrList :: [String] -> BL.ByteString
fromHexStrList xs = BL.pack $ map (\x -> read $ '0' : 'x' : x) xs 

-- ===================================================================== --

foo :: ByteString -> IO () 
foo (PS fptr off len) = withForeignPtr fptr $ \ptr -> do
    let beg = ptr `plusPtr` off
        end = beg `plusPtr` len
    putStrLn $ "fptr :" ++ (show fptr)
    putStrLn $ "ptr  :" ++ (show ptr)
    putStrLn $ "off  :" ++ (show off)
    putStrLn $ "len  :" ++ (show len)
    putStrLn $ "beg  :" ++ (show beg)
    putStrLn $ "end  :" ++ (show end)
    putStrLn $ "payload :" 
    a <- (peekByteOff ptr 0) :: IO Word8
    putStrLn $ show a
    b <- (peekByteOff (ptr `plusPtr` 1) 0) :: IO Word8
    putStrLn $ show b
    c <- (peekByteOff (ptr `plusPtr` 2) 0) :: IO Word8
    putStrLn $ show c
    d <- (peekByteOff (ptr `plusPtr` 3) 0) :: IO Word8
    putStrLn $ show d
    putStrLn $ show (shiftR d 4) 
    putStrLn $ show ((.&.) d 15) 
    return ()

showByteStringInternal :: ByteString -> IO ()
showByteStringInternal (PS fptr off len) = withForeignPtr fptr $ \ptr -> do
    let beg = ptr `plusPtr` off
        end = beg `plusPtr` len
    putStrLn $ "fptr :" ++ (show fptr)
    putStrLn $ "ptr  :" ++ (show ptr)
    putStrLn $ "off  :" ++ (show off)
    putStrLn $ "len  :" ++ (show len)
    putStrLn $ "beg  :" ++ (show beg)
    putStrLn $ "end  :" ++ (show end)

--

c1  = XM.mkCapability "tls"                       (XM.any False)
c2  = XM.mkCapability "authentication.mechanisms" (XM.mkAnyArrayAny $ (XM.mkArrayAny [XM.any ("MYSQL41" :: String)]))
c3  = XM.mkCapability "doc.formats"               (XM.any ("text" :: String))
c4  = XM.mkCapability "node_type"                 (XM.any ("mysql" :: String))
c5  = XM.mkCapability "plugin.version"            (XM.any ("1.0.2" :: String))
c6  = XM.mkCapability "client.pwd_expire_ok"      (XM.any False)

cp = XM.mkCapabilities [c1, c2, c3, c4, c5, c6]
