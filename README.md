Haskell Client Library for MySQL XProtocol
====

WORK IN PROGRESS, MANY CHANGES ARE EXPECTED.

Overview

## Description

## Examples

### Session Management

### Transaction

### SQL interface

### Document interface

## Requirement

## Install

## Contribution

## NOTE

```mysqlx_datatypes.proto``` and ```mysqlx_expr.proto``` have the same message names, ```Object``` and ```ObjectField```. But structures are different.

```
$ grep Object -r  mysql-server-rapid-plugin-x-protocol
mysql-server-rapid-plugin-x-protocol/mysqlx_datatypes.proto:message Object {
mysql-server-rapid-plugin-x-protocol/mysqlx_datatypes.proto:  message ObjectField {
mysql-server-rapid-plugin-x-protocol/mysqlx_datatypes.proto:  repeated ObjectField fld = 1;
mysql-server-rapid-plugin-x-protocol/mysqlx_datatypes.proto:  optional Object obj    = 3;
mysql-server-rapid-plugin-x-protocol/mysqlx_expr.proto:  optional Object       object = 8;
mysql-server-rapid-plugin-x-protocol/mysqlx_expr.proto:message Object {
mysql-server-rapid-plugin-x-protocol/mysqlx_expr.proto:  message ObjectField {
mysql-server-rapid-plugin-x-protocol/mysqlx_expr.proto:  repeated ObjectField fld = 1;
$
```

When we generate haskell code from *.proto files, the generated files by the one are overwrited the files by the other.  So we lose the genereated files.  This is Because they share the message names.

To workaround, I modify (modified ?) ```mysqlx_expr.proto``` as follows :

```
<   optional Object       object = 8;
---
>   optional ObjectExpr   object = 8;             // modified
241,242c241,242
< message Object {
<   message ObjectField {
---
> message ObjectExpr {                              // modified
>   message ObjectFieldExpr {                       // modified
247c247
<   repeated ObjectField fld = 1;
---
>   repeated ObjectFieldExpr fld = 1;               // modified
```

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

## Author

[naoto-gawa](https://github.com/naoto-ogawa)

## References

* X Protocol MySQL workload 
 * https://dev.mysql.com/worklog/task/?id=8639

