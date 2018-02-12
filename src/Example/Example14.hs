{-# LANGUAGE  ScopedTypeVariables #-}
{-# LANGUAGE  ConstraintKinds #-}

module Example.Example14 where

import Control.Exception.Safe (SomeException, catch)
import qualified Data.Text            as T
import           Data.Time
import qualified Data.Word            as W

-- my library
import DataBase.MySQLX.DateTime
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement

data People = People { 
    id             :: Int
  ,first_name      :: String
  ,last_name       :: String
  ,email           :: String 
  ,gender          :: Char
  ,ip_address      :: String
  ,age             :: W.Word32
  ,register_date   :: Day
  ,start_time      :: MysqlTime
  ,expire_datetime :: LocalTime
  ,rate            :: Double 
  ,message         :: T.Text 
  -- ,stock_asset     :: Ratio Int
  ,stock_asset     :: Double 
} deriving Show

people :: RowFrom People 
people = People <$> 
  colVal <*> 
  colVal <*> 
  colVal <*>
  colVal <*>
  colVal <*>
  colVal <*>
  colVal <*>
  colVal <*>
  colVal <*>
  colVal <*>
  colVal <*>
  colVal <*>
--  colVal <*> Ratio
  colValDecimalDouble -- Decimal to Double

example14 :: IO ()
example14 = do
    nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root", port=8000}
   -- catch :: (Exception e, MonadCatch m) => m a -> (e -> m a) -> m a
    catch ( do
      result <- executeRawSql "select * from people where length(message)>300" nodeSess
      -- repeat row retrival.
      print $ rowFrom people $ head result
      -- get resultset
      -- mapM_ print $ resultFrom people $ result
      ) (\(e::SomeException) -> print e)

    closeNodeSession nodeSess

{-

create table people (
   id           int
  ,first_name   VARCHAR(255)
  ,last_name    VARCHAR(255)
  ,email        VARCHAR(255)
  ,gender       char(1)
  ,ip_address   varchar(16)
  ,age          int unsigned
  ,register_date   date
  ,start_time      time
  ,expire_datetime datetime
  ,rate         Double 
  ,message      text
  ,stock_asset  Decimal(6,3)
)

mysql-sql> load data infile './src/Example/example14.csv' into table people fields terminated by ',' OPTIONALLY ENCLOSED BY '"';

-}
