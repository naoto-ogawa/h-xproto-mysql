{- |
module      : Database.MySQLX.Exception
description : Exception 
copyright   : (c) naoto ogawa, 2017
license     : MIT 
maintainer  :  
stability   : experimental
portability : 

Exceptions

-}
{-# LANGUAGE RecordWildCards #-}

module DataBase.MySQLX.Exception 
  (
    -- * Exception
     XProtocolError(..)
  ,  XProtocolException(..)
    -- * Helper functions
  , isError
  , isFatal
  , getErrorCode
  , getErrorSQLState
  , getErrorMsg
  , getExceptionMsg
    -- * handler functions
  , handleError
  , handleException
  ) where

-- general, standard library
import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM, Handler(..))
import Data.Typeable          (TypeRep, Typeable, typeRep, typeOf)
import Data.Word
import qualified Data.ByteString.Lazy as BL 

-- generated library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Error                              as PE 
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Error.Severity                     as PES 

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB
import qualified Text.ProtocolBuffers.Basic          as PBB
import qualified Text.ProtocolBuffers.Header         as PBH
import qualified Text.ProtocolBuffers.TextMessage    as PBT
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers.Reflections    as PBR

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- | An error sent by X Protocol
data  XProtocolError = XProtocolError PE.Error 
  deriving (Typeable, Show)
instance Exception XProtocolError

-- | An exception in this library
data  XProtocolException = XProtocolException String  
  deriving (Typeable, Show)
instance Exception XProtocolException

-- | check if severity of X Protocol Error is ERROR.
isError :: XProtocolError -> Bool
isError = _isSeverity PES.ERROR

-- | check if severity of X Protocol Error is FATAL.
isFatal:: XProtocolError -> Bool
isFatal = _isSeverity PES.FATAL

_isSeverity :: PES.Severity -> XProtocolError -> Bool
_isSeverity s (XProtocolError PE.Error{..}) = 
  case severity of
    Nothing -> False
    Just x  -> x == s

-- | get error code.
getErrorCode :: XProtocolError -> Int
getErrorCode (XProtocolError PE.Error{..}) = fromIntegral code 

-- | get error sql state 
getErrorSQLState :: XProtocolError -> String 
getErrorSQLState (XProtocolError PE.Error{..}) = PBH.uToString sql_state

-- | get error message.
getErrorMsg :: XProtocolError -> String
getErrorMsg (XProtocolError PE.Error{..}) = PBH.uToString msg

-- | get exception message.
getExceptionMsg :: XProtocolException -> String
getExceptionMsg (XProtocolException msg) = msg

-- | Make a handler of XProtocolError
handleError :: (XProtocolError -> m a) -> Handler m a 
handleError = Handler 

-- | Make a handler of XProtocolError
handleException :: (XProtocolException -> m a) -> Handler m a 
handleException = Handler 

