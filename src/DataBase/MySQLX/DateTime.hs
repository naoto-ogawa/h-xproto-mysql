{- |
module      : DataBase.MySQLX.DataTypes
description : DateTime 
copyright   : (c) naoto ogawa, 2017
license     : mit 
maintainer  :  
stability   : experimental
portability : 
-}

{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}

module DataBase.MySQLX.DateTime
  (
   MysqlTime
  ,XM.any  
  ,getColDay
  ,getColDay' 
  ,getColLocalTime
  ,getColLocalTime' 
  ,getColMysqlTime
  ,getColMysqlTime' 
  ,toColVal'
  ,colValDecimalDouble
  ) where

import Prelude as P

-- general, standard library
import qualified Data.Binary.Get      as BinG
import qualified Data.Binary.Strict.BitGet as Bit
import qualified Data.ByteString.Lazy as BL 
import           Data.Ratio
import qualified Data.Sequence        as Seq
import           Data.Time
-- generated library
-- protocol buffer library
-- my library
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.ResultSet
import DataBase.MySQLX.Statement   

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Day  

instance Anyable Day where 
  -- | XProtocol doesn't have date type, insted it treats Date as String. 
  any = XM.any . show

-- | retrive Day from a Row.
getColDay ::   Row  -- ^ a Row 
            -> Int  -- ^ column index 
            -> Day  -- ^ Day 
getColDay row idx = getColDay' (Seq.index row idx)

-- | from ByteString to Day. 
getColDay' :: BL.ByteString -> Day 
getColDay' = BinG.runGet getDay 

instance ColumnValuable Day where toColVal' = getColDay'

-- -----------------------------------------------------------------------------
-- LocalTime 

instance Anyable LocalTime where 
  -- | XProtocol doesn't have date type, insted it treats Date as String. 
  --   
  -- >>> let y = fromGregorian 2017 09 17
  -- >>> let t = TimeOfDay 19 23 54
  -- >>> let lt = LocalTime y t
  -- >>> lt
  -- 2017-09-17 19:23:54
  -- >>> import Text.Pretty.Simple
  -- >>> pPrint $ DataBase.MySQLX.Model.any lt
  -- Any
  --     { type' = SCALAR
  --     , scalar = Just
  --         ( Scalar
  --             { type' = V_STRING
  --             , v_signed_int = Nothing
  --             , v_unsigned_int = Nothing
  --             , v_octets = Nothing
  --             , v_double = Nothing
  --             , v_float = Nothing
  --             , v_bool = Nothing
  --             , v_string = Just
  --                 ( String
  --                     { value = "2017-09-17T19:23:54.000"
  --                     , collation = Nothing
  --                     }
  --                 )
  --             }
  --         )
  --     , obj = Nothing
  --     , array = Nothing
  --     }
  --  >>>
  any = XM.any . formatLocalTime

-- | retrive LocalTime from a Row.
getColLocalTime :: Row       -- ^ a Row 
                -> Int       -- ^ column index 
                -> LocalTime -- ^ LocalTime
getColLocalTime row idx = getColLocalTime' (Seq.index row idx)

-- | from ByteString to LocalTime. 
getColLocalTime' :: BL.ByteString -> LocalTime
getColLocalTime' = BinG.runGet getLocalTime

instance ColumnValuable LocalTime  where toColVal' = getColLocalTime'

-- -----------------------------------------------------------------------------
-- MysqlTime 

-- | Haskell type of "MySQL DataType Time"
-- MysqlTime type is Pare of Bool and TimeOfDay.
-- In case of True, we have positive time.
-- In case of False, we have negative time.
type MysqlTime = (Bool, TimeOfDay)

instance Anyable MysqlTime where 
  -- | XProtocol doesn't have date type, insted it treats Date as String. 
  any = XM.any . formatMysqlTime

-- | retrive Day from a Row.
getColMysqlTime :: Row   -- ^ a Row 
            -> Int       -- ^ column index 
            -> MysqlTime -- ^ TimeOfDay 
getColMysqlTime row idx = getColMysqlTime' (Seq.index row idx) 

-- | from ByteString to Day. 
getColMysqlTime' :: BL.ByteString -> MysqlTime 
getColMysqlTime' seq = 
  case Bit.runBitGet (BL.toStrict seq) getMysqlTime of
    Left str -> error str
    Right x  -> x

instance ColumnValuable MysqlTime where toColVal' = getColMysqlTime'

-- -----------------------------------------------------------------------------
-- parser

-- | LocalTime Parser
getLocalTime :: BinG.Get LocalTime
getLocalTime = do
  day  <- getDay
  time <- getTime
  return $ LocalTime day time

-- | MysqlTime Parser
getMysqlTime :: Bit.BitGet MysqlTime 
getMysqlTime = do
  d1 <- Bit.getBit
  d2 <- Bit.getBit
  d3 <- Bit.getBit
  d4 <- Bit.getBit
  d5 <- Bit.getBit
  d6 <- Bit.getBit
  d7 <- Bit.getBit
  d8 <- Bit.getBit -- sign  true -> negative
  hh <- Bit.getAsWord8 8
  mm <- Bit.getAsWord8 8 
  ss <- Bit.getAsWord8 8
  return $ (not d8, TimeOfDay (fromIntegral hh) (fromIntegral mm) (fromIntegral ss))

-- | Day Parser
-- If type of a column is YEAR, you get the first day of the year. 1984-01-01
getDay :: BinG.Get Day 
getDay = do
  y <- BinG.getWord16le 
  b <- BinG.isEmpty
  if b then 
    return $ fromGregorian (fromIntegral(y-2048)) 0 0 
  else do
    m <- BinG.getWord8
    d <- BinG.getWord8 
    return $ fromGregorian (fromIntegral(y-2048)) (fromIntegral (m+1)) (fromIntegral d)

-- | TimeOfDay Parser
getTime :: BinG.Get TimeOfDay
getTime = do
  hh <- BinG.getWord8 
  b <- BinG.isEmpty
  if b then 
    return $ TimeOfDay (fromIntegral hh) 0 0
    else do
      mm <- BinG.getWord8 
      b <- BinG.isEmpty
      if b then 
        return $ TimeOfDay (fromIntegral hh) (fromIntegral mm) 0
      else do
        ss <- BinG.getWord8 
        return $ TimeOfDay (fromIntegral hh) (fromIntegral mm) (fromIntegral ss) 

-- see https://hackage.haskell.org/package/iso8601-time-0.1.4/docs/src/Data-Time-ISO8601.html#formatISO8601Millis

-- | Like ISO 8601 format
-- ex) "2017-09-17T12:34:56.123"
formatLocalTime :: LocalTime -> String
formatLocalTime lt = take 23 (formatLocalTimePadded lt)

-- | zero padding for LocalTime 
formatLocalTimePadded :: LocalTime -> String
formatLocalTimePadded t
  | length str == 19 = str ++ ".000000000000"
  | otherwise        = str ++ "000000000000"
  where
    str = formatTime defaultTimeLocale "%FT%T%Q" t

-- | Timeformat for MysqlTime. 
-- ex) "12:34:56.123" or "-12:34:56.123"
formatMysqlTime :: MysqlTime-> String
formatMysqlTime (sign, tod) = if sign then str else ('-' : str)
  where str = formatTimeOfDay tod

-- | Like ISO 8601 format
-- ex) "12:34:56.123"
formatTimeOfDay :: TimeOfDay -> String
formatTimeOfDay tod = take 12 (formatTimeOfDayPadded tod)

-- | zero padding for TimeOfDay 
formatTimeOfDayPadded :: TimeOfDay -> String
formatTimeOfDayPadded tod
  | length str == 8 = str ++ ".000000000000"
  | otherwise       = str ++ "000000000000"
  where
    str = formatTime defaultTimeLocale "%T%Q" tod

-- -----------------------------------------------------------------------------
-- Decimal  

getDigitsLen :: Bit.BitGet Int
getDigitsLen = do
  v <- Bit.getWord8
  return $ fromIntegral v

getOneDec :: Bit.BitGet Int
getOneDec = do
  b3 <- Bit.getBit
  b2 <- Bit.getBit
  b1 <- Bit.getBit
  b0 <- Bit.getBit
  return $ bit2Int [b3, b2, b1, b0]

getListDec :: Bit.BitGet [Int]
getListDec = do
  e <- Bit.isEmpty
  if e 
    then return []
    else do x  <- getOneDec
            xs <- getListDec
            return (x:xs)

getDecimal :: ([Int] -> Int -> Bool -> a) -> Bit.BitGet a
getDecimal fun = do
  dl   <- getDigitsLen
  decs <- getListDec
  let len  = P.length decs
      pad  = last decs == 0
      sign = if pad then decs !! (len-2) == 12 else last decs == 12
      dcb  = if pad then init (init decs)      else init decs
  return $ fun (map fromIntegral dcb) dl sign 

getDecimalRatio:: (Integral a) => Bit.BitGet (Ratio a)
getDecimalRatio = getDecimal decodeRatio

getDecimalDouble :: Bit.BitGet Double 
getDecimalDouble = getDecimal decodeDouble

decodeDouble :: [Int] -> Int -> Bool -> Double -- TODO throw exception
decodeDouble num frac sign = (sumtimes (map fromIntegral num) base) * (bool2Sign sign)
   where
      len = P.length num
      power = [(len - frac - 1), (len - frac - 2) .. (-frac) ]
      base :: [Double]
      base  = P.map (\x -> 10^^x) power 

decodeRatio :: (Integral a) => [Int] -> Int -> Bool -> Ratio a -- TODO throw exception
decodeRatio num frac sign = (((sumtimes (map fromIntegral num) base) % base')) * (bool2Sign sign)
   where
      len = P.length num
      base  = bases len 
      base' = head $ bases frac 

bases :: (Num a1, Num a, Enum a) => a -> [a1]
bases xs = P.foldr (\x acc -> P.head acc * 10 : acc) [1] [2..xs]

bool2Sign :: (Num a) => Bool -> a
bool2Sign sign = if sign then 1 else -1

-- | fusing zipWith (*) and sum
-- https://qiita.com/nobsun/items/37d6cc2505af0a3a252f
-- sumtimes :: [Int] -> [Int] -> Int
sumtimes :: (Num a) => [a] -> [a] -> a
sumtimes = foldr fuser (const 0)
  where
    fuser x k []     = 0
    fuser x k (y:ys) = (x * y) + k ys

-- | converts bits to Int.
bit2Int :: [Bool]  -- | bits (ex. 0101 -> [False, True, False, True])
           -> Int  -- | Int value (ex. 5)
bit2Int bits = foldZipWith (+) 0 (\x y -> if y then x else 0) base bits 
   where base = (P.map (\x -> 2^x) [len,(len-1)..0])
         len  = P.length bits - 1

-- | fold and zipWith
foldZipWith :: (c -> c -> c)    -- folding function
               -> c             -- initial value
               -> (a -> b -> c) -- zipping functin 
               -> [a]           -- list 1
               -> [b]           -- list 2
               -> c             -- result
foldZipWith foldFun initial zipFun = foldr fuser (const initial)
  where
    fuser x k []     = initial
    fuser x k (y:ys) = foldFun (zipFun x y) (k ys)

-- | retrive Decimal as Double from a Row.
getColDecimalDouble :: Row   -- ^ a Row 
            -> Int       -- ^ column index 
            -> Double    -- ^ TimeOfDay 
getColDecimalDouble row idx = getColDecimalDouble' (Seq.index row idx) 

-- | from ByteString to Decimal as Double 
getColDecimalDouble' :: BL.ByteString -> Double 
getColDecimalDouble' seq = 
  case Bit.runBitGet (BL.toStrict seq) getDecimalDouble of
    Left str -> error str
    Right x  -> x

-- instance ColumnValuable Double where toColVal' = getColDecimalDouble'
colValDecimalDouble :: RowFrom Double
colValDecimalDouble = RowFrom $ \seq -> (getColDecimalDouble' $ Seq.index seq 0, Seq.drop 1 seq)

-- | retrive Decimal as Ratio from a Row.
getColDecimalRatio :: (Integral a)
            => Row     -- ^ a Row 
            -> Int     -- ^ column index 
            -> Ratio a -- ^ TimeOfDay 
getColDecimalRatio row idx = getColDecimalRatio' (Seq.index row idx) 

-- | from ByteString to Decimal as Ratio 
getColDecimalRatio' :: (Integral a) => BL.ByteString -> Ratio a
getColDecimalRatio' seq = 
  case Bit.runBitGet (BL.toStrict seq) getDecimalRatio of
    Left str -> error str
    Right x  -> x

instance (Integral a) => ColumnValuable (Ratio a) where toColVal' = getColDecimalRatio'


