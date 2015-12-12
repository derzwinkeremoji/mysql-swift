//
//  MySQLConnectionTestCase.swift
//  syncserver
//
//  Created by Steve Tibbett on 2015-12-11.
//  Copyright © 2015 Fall Day Software Inc. All rights reserved.
//

import XCTest
import swiftmysql

class MySQLConnectionTestCase: XCTestCase {

    let connection = MySQLConnection()
    
    let createUsersTableSQL = "CREATE  TABLE test_users ( `id` INT NOT NULL AUTO_INCREMENT , `email` VARCHAR(255) NULL , `pwhash` VARCHAR(255) NULL , `lastlogin` DATETIME NULL , PRIMARY KEY (`id`) );"

    override func setUp() {
        super.setUp()
        
        try! connection.connect(TestEnvironment.testhost, user: TestEnvironment.testuser, password: TestEnvironment.testpass, database: TestEnvironment.testdb)
        

        try! connection.query("DROP TABLE IF EXISTS test_users")
        try! connection.query(createUsersTableSQL)
    }
    
    func testExample() {
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
