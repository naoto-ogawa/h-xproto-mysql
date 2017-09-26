{- |
module      : DataBase.MySQLX.DataTypes
description : utilties 
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
   XM.any  
  ,getColDay
  ,getColDay' 
  ,getColLocalTime
  ,getColLocalTime' 
  ,getColMysqlTime
  ,getColMysqlTime' 
  ,toColVal
  ) where
 
-- general, standard library
import qualified Data.Binary          as Bin
import qualified Data.Binary.Get      as BinG
import qualified Data.Binary.Strict.BitGet as SBinG
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Int             as I
import qualified Data.Sequence        as Seq
import           Data.Time
-- generated library
-- protocol buffer library
-- my library
import DataBase.MySQLX.Model          as XM
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
getColDay :: Seq.Seq BL.ByteString  -- ^ a Row 
            -> Int                  -- ^ column index 
            -> Day                  -- ^ Day 
getColDay seq idx = getColDay' (Seq.index seq idx)

-- | from ByteString to Day. 
getColDay' :: BL.ByteString -> Day 
getColDay' = BinG.runGet getDay 

instance ColumnValuable Day where toColVal = getColDay'

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
getColLocalTime :: Seq.Seq BL.ByteString  -- ^ a Row 
                -> Int                    -- ^ column index 
                -> LocalTime              -- ^ LocalTime
getColLocalTime seq idx = getColLocalTime' (Seq.index seq idx)

-- | from ByteString to LocalTime. 
getColLocalTime' :: BL.ByteString -> LocalTime
getColLocalTime' = BinG.runGet getLocalTime

instance ColumnValuable LocalTime  where toColVal = getColLocalTime'

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
getColMysqlTime :: Seq.Seq BL.ByteString  -- ^ a Row 
            -> Int                        -- ^ column index 
            -> MysqlTime -- ^ TimeOfDay 
getColMysqlTime seq idx = getColMysqlTime' (Seq.index seq idx) 

-- | from ByteString to Day. 
getColMysqlTime' :: BL.ByteString -> MysqlTime 
getColMysqlTime' seq = 
  case SBinG.runBitGet (BL.toStrict seq) getMysqlTime of
    Left str -> error str
    Right x  -> x

instance ColumnValuable MysqlTime where toColVal = getColMysqlTime'

-- -----------------------------------------------------------------------------
-- parser

-- | LocalTime Parser
getLocalTime :: BinG.Get LocalTime
getLocalTime = do
  day  <- getDay
  time <- getTime
  return $ LocalTime day time

-- | MysqlTime Parser
getMysqlTime :: SBinG.BitGet MysqlTime 
getMysqlTime = do
  d1 <- SBinG.getBit
  d2 <- SBinG.getBit
  d3 <- SBinG.getBit
  d4 <- SBinG.getBit
  d5 <- SBinG.getBit
  d6 <- SBinG.getBit
  d7 <- SBinG.getBit
  d8 <- SBinG.getBit -- sign  true -> negative
  hh <- SBinG.getAsWord8 8
  mm <- SBinG.getAsWord8 8 
  ss <- SBinG.getAsWord8 8
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
