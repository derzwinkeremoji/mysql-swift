//
//  MySQLField.swift
//  swiftmysql
//
//  Created by Steve Tibbett on 2015-12-15.
//  Copyright © 2015 Fall Day Software Inc. All rights reserved.
//

import Foundation


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

