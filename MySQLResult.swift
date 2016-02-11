//
//  MySQLResult.swift
//  swiftmysql
//
//  Created by Steve Tibbett on 2015-12-15.
//  Copyright © 2015 Fall Day Software Inc. All rights reserved.
//

import Foundation

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
    
    func fetchRow() throws -> Dictionary<String, Any?>? {
        let mysql_row = mysql_fetch_row(mysql_res)
        if mysql_row == nil {
            return nil
        }
        
        var dict = Dictionary<String, Any?>()
        
        // Populate the row dictionary
        for fieldIdx in 0..<numFields {
            let rowBytes = mysql_row[fieldIdx]
            let field = MySQLField(mysql_field: fields[fieldIdx])
        
            let stringValue = String.fromCString(rowBytes) ?? ""

            switch (field.type) {
                case MYSQL_TYPE_VAR_STRING:
                    dict[field.name] = stringValue
                case MYSQL_TYPE_LONGLONG:
                    let int64value = Int64(stringValue)
                    dict[field.name] = int64value
                case MYSQL_TYPE_DATETIME:
                    let dateFmt = NSDateFormatter()
                    dateFmt.timeZone = NSTimeZone.defaultTimeZone()
                    dateFmt.dateFormat = "yyyy-MM-dd hh:mm:ss"
                    dict[field.name] = dateFmt.dateFromString(stringValue)!
                case MYSQL_TYPE_BLOB:
                    let data = row_data(rowBytes, fieldIndex: fieldIdx)
                    dict[field.name] = data
                
                default:
                    throw MySQLConnection.MySQLError.UnsupportedTypeInResult(fieldName: field.name, type: field.type)
            }
        }
        
        return dict
    }
    
    func row_data(bytes: UnsafeMutablePointer<Int8>, fieldIndex: Int) -> NSData {
        let lengths = UnsafeMutablePointer<UInt64>(mysql_fetch_lengths(mysql_res))
        let fieldLength = Int(lengths[fieldIndex])
        let data = NSData(bytes: bytes, length: fieldLength)

        return data
    }
}

