module Example.Example03_data where

-- +----+----------+-------------+----------+-------------------------+
-- | ID | Name     | CountryCode | District | Info                    |
-- +----+----------+-------------+----------+-------------------------+
-- |  1 | Kabul    | AFG         | Kabol    | {"Population": 1780000} |
-- |  2 | Qandahar | AFG         | Qandahar | {"Population": 237500}  |
-- +----+----------+-------------+----------+-------------------------+
data MyRecord = MyRecord {id :: Int, name :: String, country_code :: String, district :: String, info :: String} deriving (Show, Eq)
