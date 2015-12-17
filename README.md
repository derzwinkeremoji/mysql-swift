# swift-mysql

Swift framework for accessing a MySQL database by directly calling into the MySQL C API.

## Purpose

In order to use Swift in a server environment, we need to connect to a database.  This is a simple Swift wrapper for the [MySQL C API](http://dev.mysql.com/doc/refman/5.7/en/c-api.html).

The goal is to support building server-side applications running on Linux. There are many pieces that 
need to fall into place for this, and database connectivity is just one. So for now, this project runs on the Mac, and
until Swift's package manager is ready, doesn't use any package manager. It's a standalone project that has 
classes that connect to MySQL.

## Current Status

Very early. Lets you connect to the database, and perform queries using String or Int types.

## Running

The Xcode project currently depends on the MySQL libmysqlclient.18.dylib library, which you are expected to have installed 
in the usual place (/usr/local/mysql/lib).  Otherwise, it's self-contained.

## Example

```Swift
let db = MySQLConnection()
db.connect("localhost", user: "root", password: "secret", database: "testdb")
db.query("INSERT INTO foo (field1, field2) VALUES (?, ?)", ["One", 42])
```

```Swift
let result = db.query("SELECT field1, field2 FROM foo")
print("Values: \(result["field1"], result["field2"])")
```
