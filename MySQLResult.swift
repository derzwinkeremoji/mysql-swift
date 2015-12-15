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
    
    func fetchRow() -> Dictionary<String, AnyObject?>? {
        let mysql_row = mysql_fetch_row(mysql_res)
        if mysql_row == nil {
            return nil
        }
        
        var dict = Dictionary<String, AnyObject?>()
        
        // Populate the row dictionary
        for fieldIdx in 0..<numFields {
            let rowdata = mysql_row[fieldIdx]
            let field = MySQLField(mysql_field: fields[fieldIdx])
            print("Field \(field.name) type \(field.type)")
            dict[field.name] = String.fromCString(rowdata)
        }
        
        return dict
    }
}

