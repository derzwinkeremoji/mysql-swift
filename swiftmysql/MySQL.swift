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
        case UnsupportedTypeInBind
        case UnsupportedTypeInResult(fieldName: String, type: enum_field_types)
    }
    
    let conn = mysql_init(nil)
    
    func connect(host: String, user: String, password: String, database: String, port: UInt32 = 0, flags: UInt = 0) throws {
        if (mysql_real_connect(conn, host, user, password, database, port, nil, flags) == nil) {
            throw MySQLError.ConnectFailed
        }
    }

    /**
     Execute SQL, do not expect a result
     */
    func execute(sql: String) throws {
        let result = mysql_query(conn, sql)
        if (result != 0) {
            let errorMessage = String.fromCString(mysql_error(conn)) ?? "Unknown error"
            throw MySQLError.QueryFailed(mysqlErrorCode: UInt32(result), mysqlErrorMessage: errorMessage)
        }
    }

    /**
     Simple query method
    */
    func query(sql: String) throws -> MySQLResult? {
        try execute(sql);
        
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
    func query(sql: String, params: [Any?]) throws -> MySQLResult? {
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
        
        let mysqlBind = try bindParams(params)
        
        if (mysql_stmt_bind_param(statement, UnsafeMutablePointer<MYSQL_BIND>(mysqlBind)) != 0) {
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
    
    func bindParams(params: [Any?]) throws -> [MYSQL_BIND] {
        var bindParams = [MYSQL_BIND]()
        for paramIdx in 0..<params.count {
            let paramObj = params[paramIdx]
            var bind = MYSQL_BIND()
            
            // Useful type mapping documentation
            // https://dev.mysql.com/doc/refman/5.7/en/c-api-prepared-statement-type-codes.html
            
            switch (paramObj) {
            case is String:
                let paramString = paramObj as! String
                bind.buffer_type = MYSQL_TYPE_VARCHAR
                bind.buffer_length = UInt(paramString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                
                if let cString = paramString.cStringUsingEncoding(NSUTF8StringEncoding) {
                    bind.buffer = UnsafeMutablePointer<Void>(strdup(cString))
                }
                
            case is Int:
                var paramInt64 = Int64(paramObj as! Int)
                bind.buffer_type = MYSQL_TYPE_LONGLONG
                bind.buffer_length = 8
                bind.buffer = UnsafeMutablePointer<Void>(malloc(8))
                memcpy(bind.buffer, &paramInt64, 8)
                
            case is NSDate:
                let paramDate = paramObj as! NSDate
                let calendar = NSCalendar.currentCalendar()
                let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: paramDate)

                var mysqlTime = MYSQL_TIME(year: UInt32(dateComponents.year), month: UInt32(dateComponents.month), day: UInt32(dateComponents.day), hour: UInt32(dateComponents.hour), minute: UInt32(dateComponents.minute), second: UInt32(dateComponents.second), second_part: UInt(dateComponents.nanosecond / 1000), neg: Int8(0), time_type: MYSQL_TIMESTAMP_DATETIME)
                bind.buffer_type = MYSQL_TYPE_DATETIME
                bind.buffer_length = UInt(sizeof(MYSQL_TIME))
                bind.buffer = UnsafeMutablePointer<Void>(malloc(sizeof(MYSQL_TIME)))
                memcpy(bind.buffer, &mysqlTime, Int(bind.buffer_length))
                
            default:
                throw MySQLError.UnsupportedTypeInBind
            }
            
            bindParams.append(bind)
            free(bind.buffer)
        }
        
        return bindParams
    }
}

