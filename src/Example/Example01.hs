{-# LANGUAGE  ScopedTypeVariables #-}

module Example.Example01 where

import Control.Exception.Safe
import qualified Data.ByteString      as B
import qualified Data.ByteString.Lazy as BL 
import qualified Data.Sequence        as Seq
import qualified Data.Text            as T
import qualified Data.Text.Encoding   as TE
import qualified Data.Word            as W

import qualified  Com.Mysql.Cj.Mysqlx.Protobuf.ColumnMetaData                     as PCMD


-- my library
import DataBase.MySQLX.Exception
import DataBase.MySQLX.Model          as XM
import DataBase.MySQLX.NodeSession
import DataBase.MySQLX.Statement
import DataBase.MySQLX.Util

--
-- error handling
--
example04 :: IO ()
example04 = do
  putStrLn "start example04 #########################"

  putStrLn "start braket 1 --------------------------"
  bracket
    -- frist
    (openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"})
    -- last
    (closeNodeSession)
    -- in between
    (executeRawSql "select * from city limit 2")  -- error occurs, because of schema differences. 

  putStrLn "start braket 2 --------------------------"
  bracket
    -- frist
    (openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"})
    -- last
    (closeNodeSession)
    -- in between
    (\nodeSess -> do
        ret@(x:xs) <- executeRawSql "select * from foo" nodeSess
        mapM_ printRow ret
    )

  putStrLn "start braket 3 --------------------------"
  -- "create table bazz (id int primary key);"
  -- no records
  bracket
    -- frist
    (do 
       nodeSess <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}
       begenTrxNodeSession nodeSess
       return nodeSess
    )
    -- last
    (\nodeSess -> do
       closeNodeSession  nodeSess
       return nodeSess
    )
    -- in between
    (\nodeSess -> do
         ret1 <- updateRawSql "insert into bazz values (1)" nodeSess
         ret2 <- updateRawSql "insert into bazz values (1)" nodeSess
         print $ "ret1=" ++ (show ret1) ++ ", " ++ "ret2=" ++ (show ret2)
         commitNodeSession nodeSess
         return nodeSess
       
       `catches` 
         [
           handleError (\ex -> do
              print $ "catching XProtocolError :" ++ (show ex) 
              rollbackNodeSession nodeSess
              return nodeSess 
           )
--            Handler $ \(ex :: XProtocolError) -> do
--              print $ "catching XProtocolError :" ++ (show ex) 
--              rollbackNodeSession nodeSess
--              return nodeSess 
         , handleException $ (\ex -> do
             print $ "catching XProtocolException :" ++ (show ex) 
             rollbackNodeSession nodeSess
             return nodeSess 
           )
         ]
--        `catch`
--          \(e :: SomeException)-> do
--            case e of
--              XProtocolError ex -> print $ "catching XProtocolError :" ++ (show ex) 
--              XProtocolException ex -> print $ "catching XProtocolException :" ++ (show ex) 
--            rollbackNodeSession nodeSess
--            return nodeSess 
    )

  putStrLn "end example04 #########################"

  where 
    printRow :: Seq.Seq BL.ByteString -> IO ()
    printRow x = do
      print $ getColInt64  x 0
      print $ getColString x 1

xx :: (XProtocolError -> m a) -> Handler m a 
xx f = Handler f 


--
-- create and drop a table.
--
example03 :: IO ()
example03 = do
  putStrLn "start example03"
  node <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}

  ret1 <- updateSql "create table bar (id int(5), data varchar(100));" [] node
  print $ "crate table result = " ++ (show ret1)

  ret1 <- updateSql "drop table bar" [] node
  print $ "drop table result = " ++ (show ret1)

  closeNodeSession node
  putStrLn "end example03"

--
--  insert, update, delete and transaction.
--
example02 :: IO ()
example02 = do
  putStrLn "start example02"
  node <- openNodeSession $ defaultNodeSesssionInfo {database = "x_protocol_test", user = "root", password="root"}
  debug $ "node=" ++ (show node)
  isCon <- isSocketConnected node
  print isCon

--  insert a => insert b => update a->c => delete a => commit => update b->* => rollback

  begenTrxNodeSession node

  ret1 <- updateSql "insert into foo values (1,\"aaa\")" [] node
  print $ "insert result = " ++ (show ret1)

  ret6 <- updateSql "insert into foo values (2,\"bbb\")" [] node
  print $ "insert result = " ++ (show ret6)

  ret2 <- updateSql "update foo set v = ? where id = ?"  [XM.any "ccc", XM.any $ (1 :: Int)] node
  print $ "update result = " ++ (show ret2)

  ret3 <- updateSql "delete from foo where id = ?"  [XM.any $ (1 :: Int)] node
  print $ "delete result = " ++ (show ret3)

  ret4 <- commitNodeSession node :: IO W.Word64
  print $ "commit result = " ++ (show ret4)

  begenTrxNodeSession node
  
  ret <- updateSql "update foo set v = ? where id = ?"  [XM.any "***", XM.any $ (2 :: Int)] node
  print $ "update result = " ++ (show ret)

  ret5 <- rollbackNodeSession node :: IO W.Word64
  print $ "commit result = " ++ (show ret5)

  closeNodeSession node
  isCon <- isSocketConnected node

  print isCon
  putStrLn "end example02"


--
-- Select interfaces
--
example01 :: IO ()
example01 = do
  putStrLn "start example01"
  node <- openNodeSession $ defaultNodeSesssionInfo {database = "world_x", user = "root", password="root"}
  debug $ "node=" ++ (show node)
  isCon <- isSocketConnected node
  print isCon
  
  select1 node

--  select2 node
--
--  select3 node
--
--  select4 node
--
--  -- metadata
--  select11 node

  closeNodeSession node
  isCon <- isSocketConnected node

  print isCon
  putStrLn "end example01"

select1 :: NodeSession -> IO () 
select1 node = do
  print "start select 1 ---------- "
  ret@(x:xs) <- executeRawSql "select * from city limit 2" node
  mapM_ printRow ret
  print "end   select 1 ---------- "

select2 :: NodeSession -> IO ()
select2 node = do
  print "start select 2 ---------- "
  ret@(x:xs) <- executeSql "select * from city limit ?" [XM.any $ (3 :: Int)] node
  mapM_ printRow ret
  print "end   select 2 ---------- "

select3 :: NodeSession -> IO ()
select3 node = do
  print "start select 3 ---------- "
  ret@(x:xs) <- executeSql "select * from city where CountryCode = ? limit ?" [XM.any "AFG", XM.any $ (3 :: Int)] node
  mapM_ printRow ret
  print "end   select 3 ---------- "

select4 :: NodeSession -> IO ()
select4 node = do
  print "start select 4 ---------- "
  ret@(x:xs) <- executeSql "select countrycode , count(*) as cnt from city group by countrycode order by ? desc limit ?" [XM.any "cnt", XM.any $ (10 :: Int)] node
  mapM_ printRow4 ret
  print "end   select 4 ---------- "

select11 :: NodeSession -> IO () 
select11 node = do
  print "start select 1 ---------- "
  (meta, ret@(x:xs)) <- executeRawSqlMetaData "select * from city limit 2" node
  printMetas meta
  print "end   select 1 ---------- "

printRow :: Seq.Seq BL.ByteString -> IO ()
printRow x = do
  print $ getColInt64  x 0
  print $ getColString x 1
  print $ getColString x 2
  print $ getColString x 3
  print $ getColString x 4

printRow4 :: Seq.Seq BL.ByteString -> IO ()
printRow4 x = do
  print $ getColString x 0
  print $ getColInt64 x 1

printMetas :: Seq.Seq PCMD.ColumnMetaData -> IO ()
printMetas meta = do
  let len = Seq.length meta
  mapM_ (\idx -> printMeta meta idx) [0..(len-1)]

printMeta :: Seq.Seq PCMD.ColumnMetaData -> Int -> IO ()
printMeta meta idx = do
  print $ "column meta data, idx =" ++ (show idx)
  print $ getColMetaType meta idx 
  print $ getColMetaName meta idx




