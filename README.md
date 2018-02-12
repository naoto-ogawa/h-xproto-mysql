Haskell Client Library for MySQL XProtocol
====

WORK IN PROGRESS, MANY CHANGES ARE EXPECTED.

![Worklog](https://github.com/naoto-ogawa/h-xproto-mysql/wiki/WorkLog)

Overview

## Description

## Examples

### Session Management (open and close)

Open a node session.
```haskell
nodeSess <- openNodeSession $ defaultNodeSesssionInfo {
      database = "your_database"
    , user     = "your_username"
    , password = "your_password"
    -- , host = default host is 127.0.0.1
    -- , port = default port is 33060
    }
```
Close a node session.
```haskell
closeNodeSession nodeSess
```

### Transaction

Begin a transaction.
```haskell
begenTrxNodeSession nodeSess
```

Commit a transaction.
```haskell
commitNodeSession nodeSess
```
Rollback a transaction.
```haskell
rollbackNodeSession nodeSess
```

### SQL interface

Update
```haskell
ret0 <- updateSql "create table bar (id int(5), data varchar(100));" [] nodeSess

ret1 <- updateSql "insert into foo values (1,\"aaa\")" [] nodeSess
print $ "insert result = " ++ (show ret1)

ret2 <- updateSql "update foo set v = ? where id = ?"  [XM.any "ccc", XM.any $ (1 :: Int)] nodeSess
print $ "update result = " ++ (show ret2)

ret3 <- updateSql "delete from foo where id = ?"  [XM.any $ (1 :: Int)] nodeSess
print $ "delete result = " ++ (show ret3)
```

Select (using Template Haskell)
```haskell
data MyRecord = MyRecord {
      id           :: Int
    , name         :: String
    , country_code :: String
    , district     :: String
    , info         :: String
} deriving (Show, Eq)

ret@(x:xs) <- executeRawSql "select * from city limit 2" nodeSess
print ( $(retrieveRow ''MyRecord) x )
```

Select (without Template Haskell)

[see example](https://github.com/naoto-ogawa/h-xproto-mysql/blob/master/src/Example/Example14.hs)

### Document interface

Find
```haskell
let f = PB.defaultValue 
        `setCollection` (mkCollection "world_x" "countryinfo") 
        `setDataModel`  PDM.DOCUMENT 
        `setCriteria`   (exprDocumentPathItem "name" @== expr "Mike" )

ret <- CRUD.find f nodeSess
print ret
```

Update
```haskell
let f = PB.defaultValue 
        `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
        `setDataModel`  PDM.DOCUMENT 
        `setCriteria`   (exprDocumentPathItem "name" @== expr "Jone" )
        `setOperation`  [updateItemReplace "age" (999 :: Int)]
ret <- CRUD.update f nodeSess
print ret
```

Insert
```haskell
-- Note that your json needs an uuid whose key is _id.
json1 <- insertUUIDIO "{\"name\" : \"Tom\" , \"age\" : 18 }"
 
let i1 = PB.defaultValue 
          `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
          `setDataModel`  PDM.DOCUMENT 

ret <- CRUD.insert (i1 `setTypedRow` [mkExpr2TypedRow' $ expr json1]) nodeSess
print ret
``` 

Delete
```haskell
let f = PB.defaultValue 
        `setCollection` (mkCollection "x_protocol_test" "foo_doc") 
        `setDataModel` PDM.DOCUMENT
ret <- CRUD.delete f nodeSess
print ret
```

### Pipeline

```haskell
sql1 = "insert into test_users values (1, 'mike'  , 'mike@example.com'  ,  45);"
sql2 = "insert into test_users values (2, 'nancy' , 'nancy@example.com' , 115);"
sql3 = "insert into test_users XXXXXX (3, 'steve' , 'steve@example.com' , 298);"  -- invalid sql
sql4 = "insert into test_users values (4, 'james' , 'steve@example.com' , 444);"  -- rejected by server
sql5 = "insert into test_users values (5, 'jhon'  , 'steve@example.com' , 555);"  -- rejected by server

-- short cut
exec = sendStmtExecuteSql 

-- Make a bulk of inserts
bulk :: ReaderT NodeSession IO ()
bulk = exec sql1 [] >> exec sql2 [] >> exec sql3 [] >> exec sql4 [] >> exec sql5 [] 

-- Make a pipeline
makeNoExpect sqls = do  
  sendExpectNoError
  sqls
  sendExpectClose

-- Run the pipeline
runReaderT (makeNoExpect bulk) nodeSess

-- Retreive the resultset.
ret <- runReaderT (repeatreadMessagesR True 5 ([],[])) nodeSess
```

### Do you want try-catch-finally?

Loan pattern and try-catch-finally.
```haskell
bracket
-- frist
(do
    nodeSess <- openNodeSession $ defaultNodeSesssionInfo {
          database = "x_protocol_test"
        , user     = "your_user"
        , password = "your_password"
        }
    begenTrxNodeSession nodeSess
    return nodeSess
)
-- last
(\nodeSess -> do
    closeNodeSession nodeSess
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
        , handleException $ (\ex -> do
            print $ "catching XProtocolException :" ++ (show ex)
            rollbackNodeSession nodeSess
            return nodeSess
        )
        , Handler $ (\(ex :: SomeException) -> do
            print $ "catching SomeException :" ++ (show ex)
            rollbackNodeSession nodeSess
            return nodeSess
        )
        ]
)
```

## Requirement

## Install

## Contribution

## NOTE

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

## Author

[naoto-ogawa](https://github.com/naoto-ogawa)

## References

* X Protocol MySQL workload 
  * https://dev.mysql.com/worklog/task/?id=8639

