
module DataBase.MySQLX.Exception where

import Data.Typeable          (TypeRep, Typeable, typeRep, typeOf)
import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM)

import Data.Word
import qualified Data.ByteString.Lazy as BL 

import qualified  Com.Mysql.Cj.Mysqlx.Protobuf.Error                              as PE 

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB
import qualified Text.ProtocolBuffers.Basic          as PBB
import qualified Text.ProtocolBuffers.Header         as PBH
import qualified Text.ProtocolBuffers.TextMessage    as PBT
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers.Reflections    as PBR

data XProtocolException = XProtocolError PE.Error 
                        | XProtocolExcpt String
                        deriving (Typeable, Show)


instance Exception XProtocolException 

-- data MessageGetException = MessageGetException String TypeRep deriving (Typeable)

-- instance Exception MessageGetException

-- instance Show MessageGetException where
--   show (MessageGetException s typ) = concat
--     [ "Unable to parse as "
--     , show typ
--     , ": "
--     , show s
--     ]
-- 
-- --
-- data XProtocolException = XProtocolException String
-- 
-- instance Show XProtocolException where
--   show (XProtocolException error) = "XProtocolException :: " ++ show error
-- 
-- instance Exception XProtocolException
-- 
-- --
-- data XProtocolErrorException = XProtocolErrorException PE.Error 
-- 
-- instance Exception XProtocolErrorException
-- 
-- instance Show XProtocolErrorException where
--   show (XProtocolErrorException error) = "XProtocolErrorException :: " ++ show error
-- 
-- errorMsg :: XProtocolErrorException -> String
-- errorMsg (XProtocolErrorException error) = PBB.uToString $ PE.msg error
-- 
-- errorMsg' :: XProtocolErrorException -> BL.ByteString
-- errorMsg' (XProtocolErrorException error) = PBB.utf8$ PE.msg error
-- 
-- errorCode :: XProtocolErrorException -> Word32 
-- errorCode (XProtocolErrorException error) = PE.code error
-- 
-- errorState :: XProtocolErrorException -> String
-- errorState (XProtocolErrorException error) = PBB.uToString $ PE.sql_state error
-- 
-- errorState' :: XProtocolErrorException -> BL.ByteString
-- errorState' (XProtocolErrorException error) = PBB.utf8$ PE.sql_state error

