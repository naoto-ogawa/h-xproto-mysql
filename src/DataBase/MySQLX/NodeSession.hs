{-# LANGUAGE RecordWildCards     #-}

module DataBase.MySQLX.NodeSession where


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

import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Error                              as PE 
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Frame                              as PFr
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.AuthenticateContinue as PAC
import qualified Com.Mysql.Cj.Mysqlx.Protobuf.Ok                                 as POk

-- my library
import DataBase.MySQLX.Model
import DataBase.MySQLX.Util 
import DataBase.MySQLX.Exception

--------------------------------------------------------------------------------

data NodeSession = NodeSession
    {
      _socket   :: Socket          -- TODO should hide socket
    , clientId  :: W.Word64
    , auth_data :: BL.ByteString
    } deriving Show

data NodeSessionInfo = NodeSessionInfo 
    { host     :: HostName
    , port     :: PortNumber
    , database :: String 
    , user     :: String
    , password :: String
    , charset  :: String
    } deriving Show

defaultNodeSesssionInfo = NodeSessionInfo "127.0.0.1" 33060 "" "root" "" ""

--
-- transactions
--

openNodeSession :: (MonadIO m, MonadThrow m) => NodeSessionInfo -> m NodeSession
openNodeSession sessionInfo = do

  socket <- _client (host sessionInfo) (port sessionInfo)
  let session = NodeSession socket (fromIntegral 0) BL.empty 

  x <- runReaderT _negociate session
  debug "************************"
  debug x
  debug "************************"


  (t, msg):xs <- runReaderT (_auth sessionInfo) session
  case t of 
    11 -> do                                             -- TODO
      liftIO $ print "success"
      frm <- getFrame msg
      -- liftIO $ print frm
      case PFr.payload frm of
        Just x  -> do 
          changed <- getSessionStateChanged $ BL.toStrict x
          liftIO $ print changed
          ok <- mkAuthenticateOk $ snd $ head xs 
          liftIO $ print ok 
          id <- getClientId changed
          debug $ "NodeSession is opend; clientId =" ++ (show id)
          return session {clientId = id} 
        Nothing -> throwM $ XProtocolExcpt "Payload is Nothing" -- liftIO $ print "nothing"
    1  -> do                                            -- TODO
      err <- getError msg
      throwM $ XProtocolError err
    _  -> error $ "message type unknown, =" ++ show t

closeNodeSession ::  (MonadIO m, MonadThrow m) => NodeSession -> m ()
closeNodeSession nodeSess = do
  runReaderT (sendClose >> recieveOk) nodeSess
  liftIO . close $ _socket nodeSess
  debug "NodeSession is closed."
  return ()

_client :: (MonadIO m) => HostName -> PortNumber -> m Socket  -- TODO hiding
_client host port = liftIO $ withSocketsDo $ do
  addrInfo <- getAddrInfo Nothing (Just host) (Just $ show port)
  let serverAddr = head addrInfo
  sock <- socket (addrFamily serverAddr) Stream defaultProtocol
  connect sock (addrAddress serverAddr)
  return sock

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

_auth :: (MonadIO m, MonadThrow m) => NodeSessionInfo -> ReaderT NodeSession m [(Int, B.ByteString)]
_auth NodeSessionInfo{..} = do
 sendAuthenticateStart user
 salt <- recieveSalt
 sendAutenticateContinue database user password salt
 msgs <- readMessagesT 
 return msgs 

sendCapabilitiesGet :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m () 
sendCapabilitiesGet = writeMessageR mkCapabilitiesGet 

_negociate :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m [(Int, B.ByteString)]
_negociate = do
  sendCapabilitiesGet
  ret@(x:xs) <- readMessagesT 
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
  msg <- getAuthenticateContinueT
  return $ BL.toStrict $ PAC.auth_data msg

recieveOk :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m POk.Ok
recieveOk = getOkT


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

writeMessageR :: (PBT.TextMsg           msg
                 ,PBR.ReflectDescriptor msg
                 ,PBW.Wire              msg
                 ,Show                  msg
                 ,Typeable              msg
                 ,MonadIO               m  ) => msg -> ReaderT NodeSession m () 
writeMessageR msg = do 
  session <- ask
  liftIO $ writeMessage session msg


getErrorT :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m PE.Error 
getErrorT = readOneMessageT >>= \(_, msg) -> getError msg 


getFrameT :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m PFr.Frame 
getFrameT = readOneMessageT >>= \(_, msg) -> getFrame msg 

getAuthenticateContinueT :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m PAC.AuthenticateContinue
getAuthenticateContinueT = readOneMessageT >>= \(_, msg) -> getAuthenticateContinue msg 

getOkT :: (MonadIO m, MonadThrow m) => ReaderT NodeSession m POk.Ok
getOkT = readOneMessageT >>= \(_, msg) -> getOk msg 

getOneMessageT :: (MonadIO               m
                  ,MonadThrow            m
                  ,PBW.Wire              a
                  ,PBR.ReflectDescriptor a
                  ,PBT.TextMsg           a
                  ,Typeable              a) => ReaderT NodeSession m a
getOneMessageT = do 
  session <- ask 
  (_, msg) <- liftIO $  readOneMessage session
  getMessage msg 

readMessages :: (MonadIO m) => NodeSession -> m [(Int, B.ByteString)]
readMessages NodeSession{..} = do
   len <- runReaderT readMsgLengthT _socket
   liftIO $ print $ "1st length =" ++ (show $ getIntFromLE len)
   ret <- runReaderT (readAllMsgT (fromIntegral $ getIntFromLE len)) _socket
   return ret

readMessagesT :: (MonadIO m) => ReaderT NodeSession m [(Int, B.ByteString)] 
readMessagesT = ask >>= liftIO . readMessages

readOneMessage :: (MonadIO m) => NodeSession -> m (Int, B.ByteString)
readOneMessage NodeSession{..} = runReaderT readOneMsgT _socket 

readOneMessageT :: (MonadIO m) => ReaderT NodeSession m (Int, B.ByteString)
readOneMessageT = ask >>= liftIO . readOneMessage 

readNMessage :: (MonadIO m) => Int -> NodeSession -> m [(Int, B.ByteString)]
readNMessage n NodeSession{..} = runReaderT (readNMsgT n) _socket 

readNMessageT :: (MonadIO m) => Int -> ReaderT NodeSession m [(Int, B.ByteString)]
readNMessageT n = ask >>= liftIO . readNMessage n

--
-- Using Socket 
--

readSocketT :: (MonadIO m) => Int -> ReaderT Socket m B.ByteString
readSocketT len = ask >>= (\x -> liftIO $ recv x len) 

readMsgLengthT :: (MonadIO m) => ReaderT Socket m B.ByteString
readMsgLengthT = readSocketT 4

readMsgTypeT :: (MonadIO m) => ReaderT Socket m B.ByteString
readMsgTypeT = readSocketT 1

readNextMsgT :: (MonadIO m) => Int -> ReaderT Socket m (B.ByteString, B.ByteString)
readNextMsgT len = do 
  bytes <- readSocketT (len + 4)
  return $ if B.length bytes == len 
  then
    (bytes, B.empty)
  else 
    B.splitAt len bytes

readOneMsgT :: (MonadIO m) => ReaderT Socket m (Int, B.ByteString)
readOneMsgT = do
   l <- readMsgLengthT
   t <- readMsgTypeT
   m <- readSocketT $ fromIntegral $ (getIntFromLE l) -1 
   return (byte2Int t, m)

readNMsgT :: (MonadIO m) => Int -> ReaderT Socket m [(Int, B.ByteString)]
readNMsgT n = sequence $ take n . repeat $ readOneMsgT

readAllMsgT :: (MonadIO m) => Int -> ReaderT Socket m [(Int, B.ByteString)]
readAllMsgT len = do
  t <- readMsgTypeT
  let t' = byte2Int t   
  if t' == s_sql_stmt_execute_ok then -- SQL_STMT_EXECUTE_OK is the last message and has no data.
    return [(s_sql_stmt_execute_ok, B.empty)]
  else do
    debug $ "type=" ++ (show $ byte2Int t) ++ ", readking len=" ++ (show (len-1 `max` 0)) ++ " , plus 4 byte"
    (msg, len) <- readNextMsgT (len-1)
    debug $ (show msg) ++ " , next length of readking chunk byte is " ++ (show $ if B.null len then 0 else getIntFromLE len)
    if B.null len 
    then 
      return [(t', msg)]
    else do
      msgs <- readAllMsgT $ fromIntegral $ getIntFromLE len
      return $ (t', msg): msgs 
--
-- transaction
--

begenTrxNodeSession :: (MonadIO m, MonadThrow m) => NodeSession -> m W.Word64
begenTrxNodeSession = doSimpleSessionStateChangeStmt "begin"

commitNodeSession :: (MonadIO m, MonadThrow m) => NodeSession -> m W.Word64
commitNodeSession = doSimpleSessionStateChangeStmt "commit"

rollbackNodeSession :: (MonadIO m, MonadThrow m) => NodeSession -> m W.Word64
rollbackNodeSession = doSimpleSessionStateChangeStmt "rollback"

-- 
-- helper
-- 
doSimpleSessionStateChangeStmt :: (MonadIO m, MonadThrow m) => String -> NodeSession -> m W.Word64
doSimpleSessionStateChangeStmt sql nodeSess = do 
  debug $ "session state change statement : " ++ sql
  runReaderT (writeMessageR (mkStmtExecuteSql sql [])) nodeSess
  ret@(x:xs) <- runReaderT readMessagesT nodeSess                           -- [(Int, B.ByteString)]
  if fst x == 1 then do
    msg <- getError $ snd x
    throwM $ XProtocolError msg
  else do
    frm <- (getFrame . snd ) $ head $ filter (\(t, b) -> t == s_notice) ret  -- Frame
    ssc <- getPayloadSessionStateChanged frm
    getRowsAffected ssc

byte2Int :: B.ByteString -> Int
byte2Int = fromIntegral . B.head

isSocketConnected :: NodeSession -> IO Bool 
isSocketConnected NodeSession{..} = do 
  isConnected _socket

