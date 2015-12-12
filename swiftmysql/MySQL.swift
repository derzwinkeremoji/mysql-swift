//
//  main.swift
//  swiftmysql
//
//  Created by Steve Tibbett on 2015-12-09.
//  Copyright © 2015 Fall Day Software Inc. All rights reserved.
//

import Foundation

class MySQLConnection {
    enum MySQLError: ErrorType {
        case ConnectFailed
        case QueryFailed(mysqlErrorCode: UInt32, mysqlErrorMessage: String)
        case UseResultFailed(mysqlErrorCode: UInt32, mysqlErrorMessage: String)
    }
    
    let conn = mysql_init(nil)
    
    func connect(host: String, user: String, password: String, database: String, port: UInt32 = 0, flags: UInt = 0) throws {
        if (mysql_real_connect(conn, host, user, password, database, port, nil, flags) == nil) {
            throw MySQLError.ConnectFailed
        }
    }
    
    func query(sql: String) throws -> MySQLResult? {
        let result = mysql_query(conn, sql)
        if (result != 0) {
            let errorMessage = String.fromCString(mysql_error(conn)) ?? "Unknown error"
            throw MySQLError.QueryFailed(mysqlErrorCode: UInt32(result), mysqlErrorMessage: errorMessage)
        }
        
        if (mysql_field_count(conn) > 0) {
            let mysql_res = mysql_use_result(conn)
            if mysql_res == nil {
                let err = mysql_errno(conn)
                let errorMessage = String.fromCString(mysql_error(conn)) ?? "Unknown error"
                throw MySQLError.UseResultFailed(mysqlErrorCode: UInt32(err), mysqlErrorMessage: errorMessage)
            }
            
            return MySQLResult(mysql_res: mysql_res)
        } else {
            return nil
        }
    }
}

// TODO: Make this iterable
class MySQLResult {
    let mysql_res: UnsafeMutablePointer<MYSQL_RES>
    let numFields: Int
    let fields: UnsafeMutablePointer<MYSQL_FIELD>

    init(mysql_res: UnsafeMutablePointer<MYSQL_RES>) {
        self.mysql_res = mysql_res
        self.numFields = Int(mysql_num_fields(mysql_res))
        self.fields = mysql_fetch_fields(mysql_res)
    }
    
    deinit {
        mysql_free_result(mysql_res)
    }
    
    func fetchRow() -> Dictionary<String, AnyObject?>? {
        let mysql_row = mysql_fetch_row(mysql_res)
        if mysql_row == nil {
            return nil
        }

        let dict = Dictionary<String, AnyObject?>()
        
        // Populate the row dictionary
        for fieldIdx in 0..<numFields {
            let value = mysql_row[fieldIdx]
            let field = MySQLField(mysql_field: fields[fieldIdx])
            print("Field \(field.name) type \(field.type)")

            let str = String.fromCString(value)
            print("String value \(str)")

            
        }
        
        return dict
    }
}

class MySQLField {
    let mysql_field: MYSQL_FIELD
    init(mysql_field: MYSQL_FIELD) {
        self.mysql_field = mysql_field
    }
    
    var name: String {
        get {
            return String.fromCString(mysql_field.name) ?? ""
        }
    }
    
    var type: enum_field_types {
        get {
            return mysql_field.type
        }
    }
}


//let db = MySQLConnection()
//try db.connect("localhost", user: "root", password: "", database: "mealplandev")
//let result = try db.query("select * from accounts")
//while (true) {
//    guard let row = result.fetchRow() else {
//        break
//    }
//    print("Row")
//}
//

//let res = mysql_use_result(conn)
//
//while (true) {
//    let row = mysql_fetch_row(res)
//    if row == nil {
//        break;
//    }
//    print("Row");
//}

//print("Got something")
