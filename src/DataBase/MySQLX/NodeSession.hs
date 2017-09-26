{- |
module      : Database.MySQLX.NodeSession
description : Session management 
copyright   : (c) naoto ogawa, 2017
license     : MIT 
maintainer  :  
stability   : experimental
portability : 

Session (a.k.a. Connection)

-}
{-# LANGUAGE RecordWildCards #-}

module DataBase.MySQLX.NodeSession 
  (
  -- * Session Infomation
    NodeSessionInfo(..)
  , defaultNodeSesssionInfo
  -- * Node Session 
  , NodeSession(clientId, auth_data)
  -- * Session Management
  , openNodeSession
  , closeNodeSession
  -- * Transaction
  , begenTrxNodeSession
  , commitNodeSession
  , rollbackNodeSession
  -- 
  , readMessagesR 
  , writeMessageR
  -- * Helper functions
  , isSocketConnected
  ) where

-- general, standard library
import qualified Data.Binary          as BIN
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Int             as I
import Data.Typeable          (TypeRep, Typeable, typeRep, typeOf)
import qualified Data.Word            as W 

import Network.Socket hiding (recv) 
import Network.Socket.ByteString (send, sendAll, recv)

import Control.Exception.Safe (Exception, MonadThrow, SomeException, throwM)
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class

-- protocol buffer library
import qualified Text.ProtocolBuffers                as PB
import qualified Text.ProtocolBuffers.Basic          as PBB
import qualified Text.ProtocolBuffers.Header         as PBH
import qualified Text.ProtocolBuffers.TextMessage    as PBT
import qualified Text.ProtocolBuffers.WireMessage    as PBW
import qualified Text.ProtocolBuffers.Reflections    as PBR

-- generated library
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Error                              as PE 
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Frame                              as PFr
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.AuthenticateContinue               as PAC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Ok                                 as POk

-- my library
import DataBase.MySQLX.Exception
import DataBase.MySQLX.Model
import DataBase.MySQLX.Util 

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------

-- | Node Session Object
data NodeSession = NodeSession
    { _socket   :: Socket         -- ^ socket 
    , clientId  :: W.Word64       -- ^ client id given by MySQL Server
    , auth_data :: BL.ByteString  -- ^ auth_data given by MySQL Server
    } deriving Show

-- | Infomation Object of Node Session
data NodeSessionInfo = NodeSessionInfo 
    { host     :: HostName       -- ^ host name
    , port     :: PortNumber     -- ^ port nummber
    , database :: String         -- ^ database name
    , user     :: String         -- ^ user
    , password :: String         -- ^ password
    , charset  :: String         -- ^ charset
    } deriving Show

-- | Default NodeSessionInfo
-- 
--  * host     : 127.0.0.1
--  * port     : 33600
--  * database : ""
--  * user     : "root"
--  * password : ""
--  * charset  : ""
-- 
defaultNodeSesssionInfo :: NodeSessionInfo 
defaultNodeSesssionInfo = NodeSessionInfo "127.0.0.1" 33060 "" "root" "" ""

-- | a message (type, payload)
type Message = (Int, B.ByteString) 

-- -----------------------------------------------------------------------------
-- Session Management
-- -----------------------------------------------------------------------------
-- | Open node session.
openNodeSession :: (MonadIO m, MonadThrow m) 
  => NodeSessionInfo -- ^ NodeSessionInfo
  -> m NodeSession   -- ^ NodeSession
openNodeSession sessionInfo = do

  socket <- _client (host sessionInfo) (port sessionInfo)
  let session = NodeSession socket (fromIntegral 0) BL.empty 

  x <- runReaderT _negociate session

  (t, msg):xs <- runReaderT (_auth sessionInfo) session
  case t of 
    11 -> do                                             -- TODO
      debug "success"
      frm <- getFrame msg
      case PFr.payload frm of
        Just x  -> do 
          changed <- getSessionStateChanged $ BL.toStrict x
          debug changed
          ok <- mkAuthenticateOk $ snd $ head xs 
          debug ok 
          id <- getClientId changed
          debug $ "NodeSession is opend; clientId =" ++ (show id)
          return session {clientId = id} 
        Nothing -> throwM $ XProtocolException "Payload is Nothing"
    1  -> do                                            -- TODO
      err <- getError msg
      throwM $ XProtocolError err
    _  -> error $ "message type unknown, =" ++ show t

-- | Close node session.
closeNodeSession ::  (MonadIO m, MonadThrow m) => NodeSession -> m ()
closeNodeSession nodeSess = do
  runReaderT (sendClose >> recieveOk) nodeSess
  liftIO . close $ _socket nodeSess
  debug "NodeSession is closed."
  return ()

-- | Make a socket for session.
_client :: (MonadIO m) => HostName -> PortNumber -> m Socket 
_client host port = liftIO $ withSocketsDo $ do
  addrInfo <- getAddrInfo Nothing (Just host) (Just $ show port)
  let serverAddr = head addrInfo
  sock <- socket (addrFamily serverAddr) Stream defaultProtocol
  connect sock (addrAddress serverAddr)
  return sock

_auth :: (MonadIO m, MonadThrow m) => NodeSessionInfo -> ReaderT NodeSession m [Message]
_auth NodeSessionInfo{..} = do
 sendAuthenticateStart user
 salt <- recieveSalt
 sendAutenticateContinue database user password salt
 msgs <- readMessagesR 
 return msgs 

sendCapabilitiesGet :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m () 
sendCapabilitiesGet = writeMessageR mkCapabilitiesGet 

_negociate :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m [Message]
_negociate = do
  sendCapabilitiesGet
  ret@(x:xs) <- readMessagesR 
  if fst x == s_error then do
    msg <- getError $ snd x
    throwM $ XProtocolError msg
  else do
    -- cap <- getCapabilities $ snd x
    -- debug cap
    liftIO $ B.writeFile "memo/20180826_capabilities" $ snd x
    return ret 

sendAuthenticateStart :: (MonadIO m) => String -> ReaderT NodeSession m () 
sendAuthenticateStart = writeMessageR . mkAuthenticateStart

sendAutenticateContinue :: (MonadIO m) => String -> String -> String -> B.ByteString -> ReaderT NodeSession m ()
sendAutenticateContinue database user password salt = writeMessageR $ mkAuthenticateContinue database user salt password 

sendClose ::  (MonadIO m) => ReaderT NodeSession m () 
sendClose = writeMessageR mkClose

recieveSalt :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m B.ByteString
recieveSalt = do
  msg <- getAuthenticateContinueR
  return $ BL.toStrict $ PAC.auth_data msg

recieveOk :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m POk.Ok
recieveOk = getOkR


{-
interfaces as follows:

openNodeSession = do
  sendAuthenticateStart username                       (throw NetworkException)        :: aaa -> session -> param1 -> ()
  salt <- recieveSalt                                   (throw NetworkException)       :: bbb -> session -> ByteString
  sendAuthenticateContinue schema user salt password   (throw NetworkException)        :: ccc -> session -> param{ } -> ()
  reciveAuthenticateOK                                 (throw AuthenticateException)   :: ddd -> session -> ()

-}


--  {- [C]->[S] -} --  putMsg sock $ getAuthMsg "root"
--
--  {- [S]->[C] -}
--  x <- parse2AuthenticateContinue sock
--  let salt = S.toStrict $ PAC.auth_data x
--  print salt
--
--  {- [C]->[S] -}
--  putMsg sock $ getAutCont "world_x" "root" salt (B8.pack "root")
--
--  {- [S]->[C] -}
--  frame <- parse2Frame sock
--  getSessionStateChanged frame
--  parse2AuthenticateOK sock

--
-- Using NodeSession and making ReaderT
--

writeMessage :: (PBT.TextMsg           msg
                ,PBR.ReflectDescriptor msg
                ,PBW.Wire              msg
                ,Show                  msg
                ,Typeable              msg
                ,MonadIO               m  ) => NodeSession -> msg -> m () 
writeMessage NodeSession{..} msg = do
  liftIO $ sendAll _socket (BL.toStrict $ (putMessageLengthLE (len + 1)) `BL.append` ty `BL.append` bytes)
  -- liftIO $ putStrLn $ PBT.messagePutText msg 
  where 
    bytes = PBW.messagePut                          msg 
    len   = fromIntegral   $ PBW.messageSize        msg 
    ty    = putMessageType $ fromIntegral $ getClientMsgTypeNo msg

-- | write a message.
writeMessageR :: (PBT.TextMsg           msg
                 ,PBR.ReflectDescriptor msg
                 ,PBW.Wire              msg
                 ,Show                  msg
                 ,Typeable              msg
                 ,MonadIO               m  ) => msg -> ReaderT NodeSession m () 
writeMessageR msg = do 
  session <- ask
  liftIO $ writeMessage session msg

getErrorR :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m PE.Error 
getErrorR = readOneMessageR >>= \(_, msg) -> getError msg 

getFrameR :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m PFr.Frame 
getFrameR = readOneMessageR >>= \(_, msg) -> getFrame msg 

getAuthenticateContinueR :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m PAC.AuthenticateContinue
getAuthenticateContinueR = readOneMessageR >>= \(_, msg) -> getAuthenticateContinue msg 

getOkR :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m POk.Ok
getOkR = readOneMessageR >>= \(_, msg) -> getOk msg 

getOneMessageR :: (MonadIO               m
                  ,MonadThrow            m
                  ,PBW.Wire              a
                  ,PBR.ReflectDescriptor a
                  ,PBT.TextMsg           a
                  ,Typeable              a) => ReaderT NodeSession m a
getOneMessageR = do 
  session <- ask 
  (_, msg) <- liftIO $  readOneMessage session
  getMessage msg 

readMessages :: (MonadIO m) => NodeSession -> m [Message]
readMessages NodeSession{..} = do
   len <- runReaderT readMsgLengthR _socket
   debug $ "1st length =" ++ (show $ getIntFromLE len)
   ret <- runReaderT (readAllMsgR (fromIntegral $ getIntFromLE len)) _socket
   return ret

-- | retrieve messages from Node session.
readMessagesR :: (MonadIO m) => ReaderT NodeSession m [Message] 
readMessagesR = ask >>= liftIO . readMessages

readOneMessage :: (MonadIO m) => NodeSession -> m Message
readOneMessage NodeSession{..} = runReaderT readOneMsgR _socket 

readOneMessageR :: (MonadIO m) => ReaderT NodeSession m Message
readOneMessageR = ask >>= liftIO . readOneMessage 

readNMessage :: (MonadIO m) => Int -> NodeSession -> m [Message]
readNMessage n NodeSession{..} = runReaderT (readNMsgR n) _socket 

readNMessageR :: (MonadIO m) => Int -> ReaderT NodeSession m [Message]
readNMessageR n = ask >>= liftIO . readNMessage n

--
-- Using Socket 
--

readSocketR :: (MonadIO m) => Int -> ReaderT Socket m B.ByteString
readSocketR len = ask >>= (\x -> liftIO $ recv x len) 

readMsgLengthR :: (MonadIO m) => ReaderT Socket m B.ByteString
readMsgLengthR = readSocketR 4

readMsgTypeR :: (MonadIO m) => ReaderT Socket m B.ByteString
readMsgTypeR = readSocketR 1

readNextMsgR :: (MonadIO m) => Int -> ReaderT Socket m (B.ByteString, B.ByteString)
readNextMsgR len = do 
  bytes <- readSocketR (len + 4)
  return $ if B.length bytes == len 
  then
    (bytes, B.empty)
  else 
    B.splitAt len bytes

readOneMsgR :: (MonadIO m) => ReaderT Socket m Message
readOneMsgR = do
   l <- readMsgLengthR
   t <- readMsgTypeR
   m <- readSocketR $ fromIntegral $ (getIntFromLE l) -1 
   return (byte2Int t, m)

readNMsgR :: (MonadIO m) => Int -> ReaderT Socket m [Message]
readNMsgR n = sequence $ take n . repeat $ readOneMsgR

readAllMsgR :: (MonadIO m) => Int -> ReaderT Socket m [Message]
readAllMsgR len = do
  t <- readMsgTypeR
  let t' = byte2Int t   
  if t' == s_sql_stmt_execute_ok then -- SQL_STMT_EXECUTE_OK is the last message and has no data.
    return [(s_sql_stmt_execute_ok, B.empty)]
  else do
    debug $ "type=" ++ (show $ byte2Int t) ++ ", readking len=" ++ (show (len-1 `max` 0)) ++ " , plus 4 byte"
    (msg, len) <- readNextMsgR (len-1)
    debug $ (show msg) ++ " , next length of readking chunk byte is " ++ (show $ if B.null len then 0 else getIntFromLE len)
    if B.null len 
    then 
      return [(t', msg)]
    else do
      msgs <- readAllMsgR $ fromIntegral $ getIntFromLE len
      return $ (t', msg): msgs 

-- | Begin a transaction.
begenTrxNodeSession :: (MonadIO m, MonadThrow m) => NodeSession -> m W.Word64
begenTrxNodeSession = doSimpleSessionStateChangeStmt "begin"

-- | Commit a transaction.
commitNodeSession :: (MonadIO m, MonadThrow m) => NodeSession -> m W.Word64
commitNodeSession = doSimpleSessionStateChangeStmt "commit"

-- | Rollback a transaction.
rollbackNodeSession :: (MonadIO m, MonadThrow m) => NodeSession -> m W.Word64
rollbackNodeSession = doSimpleSessionStateChangeStmt "rollback"

-- 
-- helper
-- 
doSimpleSessionStateChangeStmt :: (MonadIO m, MonadThrow m) => String -> NodeSession -> m W.Word64
doSimpleSessionStateChangeStmt sql nodeSess = do 
  debug $ "session state change statement : " ++ sql
  runReaderT (writeMessageR (mkStmtExecuteSql sql [])) nodeSess
  ret@(x:xs) <- runReaderT readMessagesR nodeSess                           -- [Message]
  if fst x == 1 then do
    msg <- getError $ snd x
    throwM $ XProtocolError msg
  else do
    frm <- (getFrame . snd ) $ head $ filter (\(t, b) -> t == s_notice) ret  -- Frame
    ssc <- getPayloadSessionStateChanged frm
    getRowsAffected ssc

byte2Int :: B.ByteString -> Int
byte2Int = fromIntegral . B.head

-- | check a raw socket connectin.
isSocketConnected :: NodeSession -> IO Bool 
isSocketConnected NodeSession{..} = do 
  isConnected _socket

{-
naming rule 
  Application Data <-- recv <-- [Protocol Buffer Object] <-- get <-- [Byte Data] <-- read  <-- [Socket]
  Application Data --> send --> [Protocol Buffer Object] --> put --> [Byte Data] --> write --> [Socket]

  mkFoo --> [Protocol Buffer Object]



(a) client -> server message implementatin pattern

1) make pure function from some params to a PB object  ==> hidden

2) make the above function to Reader Monad
  --> open package

ex)
mkAuthenticateStart
|
V
sendAuthenticateStart :: (MonadIO m) => String -> ReaderT NodeSession m () 
sendAuthenticateStart = writeMessageR . mkAuthenticateStart


(b) server -> client message implemention patten

1) make pure function from ByteString to a PB object 
  ex) getAuthenticateContinue :: B.ByteString -> PAC.AuthenticateContinue ==> hidden
      getAuthenticateContinue' = getMessage 

2) make the above function to Reader Monad

3) make a function to get concrete data, not Protocol Buffer Objects  ==> open
  ex) recieveSalt :: (MonadIO m) => ReaderT NodeSession m B.ByteString

(c) client -> server -> client message implementation

1) combine (a) and (b) so that we get a turn-around function between client and server. 


-}
