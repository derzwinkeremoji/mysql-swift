//
//  MySQLConnectionTestCase.swift
//  syncserver
//
//  Created by Steve Tibbett on 2015-12-11.
//  Copyright © 2015 Fall Day Software Inc. All rights reserved.
//

import XCTest
import swiftmysql

// Test the ability to connect to the server and execute basic commands.

class ConnectionTestCase: XCTestCase {

    let dbconn = MySQLConnection()
    
    let createUsersTableSQL = "CREATE TABLE test_users ( `id` INT NOT NULL AUTO_INCREMENT , `email` VARCHAR(255) NULL , `pwhash` VARCHAR(255) NULL , `lastlogin` DATETIME NULL , PRIMARY KEY (`id`) )"
    let dropTableSQL = "DROP TABLE IF EXISTS test_users"
    
    func testDropAndCreateTable() {
        try! dbconn.connect(TestEnvironment.testhost, user: TestEnvironment.testuser, password: TestEnvironment.testpass, database: TestEnvironment.testdb)
        
        try! dbconn.query(dropTableSQL)
        try! dbconn.query(createUsersTableSQL)
    }
}
