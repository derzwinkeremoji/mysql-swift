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
        
            switch (field.type) {
                case MYSQL_TYPE_VAR_STRING:
                    dict[field.name] = String.fromCString(rowBytes)
                case MYSQL_TYPE_LONGLONG:
                    let stringValue = String.fromCString(rowBytes) ?? "0"
                    let int64value = Int64(stringValue)
                    dict[field.name] = int64value
                default:
                    throw MySQLConnection.MySQLError.UnsupportedTypeInResult(fieldName: field.name, type: field.type)
            }
        }
        
        return dict
    }
}

