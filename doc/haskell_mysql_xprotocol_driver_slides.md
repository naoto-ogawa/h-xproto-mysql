Haskell Client for MySQL X Protocol   
===

###### Naoto Ogawa ( [@naotoogawa_](https://github.com/naoto-ogawa) )

###### Ver. 0.1  

---

# What is MySQL X Protocol?

- New interface for connecting MySQL Server
  - SQL and NoSQL interfaces
- MySQL Server 5.7.12 or higher
  - X Plugin enabled
- Official Client
  - Node.js / Java / .Net / Python / MySQL Shell
- X Plugin (MySQL) <-> TCP(36000) <-> X Protocol <-> X DevAPI (Driver) 

---

# X protocol


- message structure
  - [length(4 bytes) type(1 byte) payload]+

- Defined by Protocol Buffer
- [Definitions](https://github.com/mysql/mysql-server/tree/5.7/rapid/plugin/x/protocol)
  - Negotiations
  - Data Types
  - CRUD Operations
  - Pipeline

---

# Example / X Protocol Update (1/3)

```
> tcpdump
IP localhost.60446 > localhost.33060: Flags [P.], seq 664:760, ack 752, win 50943, options [nop,nop,TS val 927166495 ecr 927166492], length 96
```

```
0x0000:  4500 0094 34a9 4000 4006 0000 7f00 0001
0x0010:  7f00 0001 ec1e 8124 c7df 7f1a e59f 4f65
0x0020:  8018 c6ff fe88 0000 0101 080a 3743 701f
0x0030:  3743 701c 5c00 0000 1312 130a 0466 7567 # 5c, 13
0x0040:  6112 0b74 6573 745f 7363 6865 6d61 1802
0x0050:  2218 0805 3214 0a02 3d3d 1208 0801 1204
0x0060:  1202 6964 1204 0806 3800 3a22 0a09 1207
0x0070:  6d65 7373 6167 6510 011a 1308 0222 0f08
0x0080:  084a 0b0a 096d 7367 332b 2b2b 2b2b 4204
0x0090:  0801 1006                              
```

> length = 5c = 16 * 5 + 12 = 92
> type   = 13 = 19 -> CRUD_UPDATE

---

# Example / X Protocol Update (2/3)

```
$ protoc-3/bin/protoc --decode_raw < memo/dump_java_crud_update_named_bind.bin
2 {
  1: "fuga"
  2: "test_schema"
}
3: 2
4 {
  1: 5
  6 {
    1: "=="
    2 {
      1: 1
      2 {
        2: "id"
      }
    }
    2 {
      1: 6
      7: 0
    }
  }
}
7 {
  1 {
    2: "message"
  }
  2: 1
  3 {
    1: 2
    4 {
      1: 8
      9 {
        1: "msg3+++++"
      }
    }
  }
}
8 {
  1: 1
  2: 6
}
```
---

# Example / X Protocol Update (3/3)

```
collection {
  name: "fuga"
  schema: "test_schema"
}
data_model: TABLE
criteria {
  type: OPERATOR
  operator {
    name: "=="
    param {
      type: IDENT
      identifier {
        name: "id"
      }
    }
    param {
      type: PLACEHOLDER
      position: 0
    }
  }
}
args {
  type: V_SINT
  v_signed_int: 3
}
operation {
  source {
    name: "message"
  }
  operation: SET
  value {
    type: LITERAL
    literal {
      type: V_STRING
      v_string {
        value: "msg3+++++"
      }
    }
  }
}
```

---

# X DevAPI
- Client Language API 
  - CRUD Operations API
  - SQL  
  - Asyncronouse
- [API Guide](https://dev.mysql.com/doc/x-devapi-userguide/en/) 

---

# Example / Data

```
mysql-sql> select * from myBooks;
+-----------------------------------------------------------------------------------------------------------------------------------------------+----------------------------------+
| doc                                                                                                                                           | _id                              |
+-----------------------------------------------------------------------------------------------------------------------------------------------+----------------------------------+
| {"_id": "0b936ff1eb73b15948e6b13599ada00e", "isbn": "12345", "title": "Effi Briest", "author": "Theodor Fontane", "currentlyReadingPage": 42} | 0b936ff1eb73b15948e6b13599ada00e |
+-----------------------------------------------------------------------------------------------------------------------------------------------+----------------------------------+
```

```
{
  "_id"   : "0b936ff1eb73b15948e6b13599ada00e"
, "isbn"  : "12345"
, "title" : "Effi Briest"
, "author": "Theodor Fontane"
, "currentlyReadingPage": 42
}
```
---

# Example / [Java API](https://github.com/mysql/mysql-connector-j/blob/release/6.0/src/demo/java/demo/x/devapi/DevApiSample.java)

```java
// connection
XSession session = new XSessionFactory().getSession(
    "mysqlx://localhost:33060/test?user=user&password=password1234"
);

// schema
Schema schema = session.getDefaultSchema();

// collection
Collection coll = schema.createCollection("myBooks", true);

// find a document
docs = coll.find(
  "$.title = 'Effi Briest' and $.currentlyReadingPage > 10"
).execute();
book = docs.next();
```
> notice : the condition above is expressed as String literal. 

---

# Haskell Client for X Protocol 

- Easy to use
  - hide x protocol details. 
- Type Safe
  - No string literal expression
- Secure
- Performance
- Well Documented

> note : can't acheaved yet. Need your help!
---

# Example / Haskell

- Connection / Transaction
- SQL
- CRUD

---

# Haskell Implementation 

- Type Class
  - Haskell Type <-> Types defined by Spec(ProtoBuf) 
- Template Haskell
  - ResultSet -> Record Type 

---

# Need more work

- Null Handling
- More friendly and type-safe API
- DataType support (Date, Time, etc.)
- Streaming Support 
- TLS support
- Asyncronous support
- Unicode support
- Publish github repository
- Test
- Document

---

## Thanks!

Copyright &copy; 2017 [Naoto Ogawa](https://github.com/naoto-ogawa)

---

