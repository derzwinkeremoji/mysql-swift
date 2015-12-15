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
        case StatementInitFailed
        case PrepareStatementFailed(mysqlErrorCode: UInt32, mysqlErrorMessage: String)
        case BindStatementFailed(mysqlErrorCode: UInt32, mysqlErrorMessage: String)
        case ExecuteStatementFailed(mysqlErrorCode: UInt32, mysqlErrorMessage: String)
    }
    
    let conn = mysql_init(nil)
    
    func connect(host: String, user: String, password: String, database: String, port: UInt32 = 0, flags: UInt = 0) throws {
        if (mysql_real_connect(conn, host, user, password, database, port, nil, flags) == nil) {
            throw MySQLError.ConnectFailed
        }
    }
    
    /** 
     Simple query method
    */
    func query(sql: String) throws -> MySQLResult? {
        let result = mysql_query(conn, sql)
        if (result != 0) {
            let errorMessage = String.fromCString(mysql_error(conn)) ?? "Unknown error"
            throw MySQLError.QueryFailed(mysqlErrorCode: UInt32(result), mysqlErrorMessage: errorMessage)
        }
        
        if (mysql_field_count(conn) > 0) {
            let mysql_res = mysql_store_result(conn)
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
    
    /**
     Query with paramters: Executed as a prepared statement.
    */
    func query(sql: String, params: [AnyObject?]) throws -> MySQLResult? {
        let statement = mysql_stmt_init(conn)
        if statement == nil {
            throw MySQLError.StatementInitFailed
        }
        
        let strBytes = sql.cStringUsingEncoding(NSUTF8StringEncoding) ?? [CChar]()
        let result = mysql_stmt_prepare(statement, strBytes, UInt(sql.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        if (result != 0) {
            let err = mysql_stmt_errno(statement)
            let errorMessage = String.fromCString(mysql_stmt_error(statement)) ?? "Unknown error"
            throw MySQLError.PrepareStatementFailed(mysqlErrorCode: UInt32(err), mysqlErrorMessage: errorMessage)
        }
        
        var bindParams = [MYSQL_BIND]()
        for paramIdx in 0..<params.count {
            let paramObj = params[paramIdx]

            if let paramString = paramObj as? String {
                var bind = MYSQL_BIND()

                bind.buffer_type = MYSQL_TYPE_VARCHAR
                bind.buffer_length = UInt(paramString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                
                if let cString = paramString.cStringUsingEncoding(NSUTF8StringEncoding) {
                    bind.buffer = UnsafeMutablePointer<Void>(strdup(cString))
                }
                
                bindParams.append(bind)
            }
        }
        
        if (mysql_stmt_bind_param(statement, UnsafeMutablePointer<MYSQL_BIND>(bindParams)) != 0) {
            let err = mysql_stmt_errno(statement)
            let errorMessage = String.fromCString(mysql_stmt_error(statement)) ?? "Unknown error"
            throw MySQLError.BindStatementFailed(mysqlErrorCode: UInt32(err), mysqlErrorMessage: errorMessage)
        }
        
        if (mysql_stmt_execute(statement) != 0) {
            let err = mysql_stmt_errno(statement)
            let errorMessage = String.fromCString(mysql_stmt_error(statement)) ?? "Unknown error"
            throw MySQLError.ExecuteStatementFailed(mysqlErrorCode: UInt32(err), mysqlErrorMessage: errorMessage)
        }
        
        if (mysql_field_count(conn) > 0) {
            let mysql_res = mysql_store_result(conn)
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

