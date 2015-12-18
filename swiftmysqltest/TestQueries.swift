//
//  TestQueries.swift
//  swiftmysql
//
//  Created by Steve Tibbett on 2015-12-16.
//  Copyright © 2015 Fall Day Software Inc. All rights reserved.
//

import XCTest

class TestQueries: XCTestCase {

    let dbconn = MySQLConnection()

    // A table that contains a variety of types we want to test
    let dropTableSQL = "DROP TABLE IF EXISTS test_queries"
    
    let createTableSQL = "CREATE  TABLE test_queries (" +
        "col_autoinc BIGINT NOT NULL AUTO_INCREMENT, " +
        "col_username VARCHAR(32) NOT NULL, " +
        "PRIMARY KEY (col_autoinc) )"
    
    // Remove and re-create the test_types table
    override func setUp() {
        super.setUp()
        
        try! dbconn.connect(TestEnvironment.testhost, user: TestEnvironment.testuser, password: TestEnvironment.testpass, database: TestEnvironment.testdb)
        
        try! dbconn.query(dropTableSQL)
        try! dbconn.query(createTableSQL)
    }

    func testSimpleMath() {
        let result = try! dbconn.query("SELECT 2+2 AS SHOULD_BE_FOUR")
        assert(result != nil)
        let row = try! result!.fetchRow()
        assert(row != nil)
        assert(row!.keys.first == "SHOULD_BE_FOUR")
        assert(row!["SHOULD_BE_FOUR"] as! Int64 == 4)
    }

    // This doesn't test specific support for autoincrement, but it does demonstrate
    // how to retrieve the ID of an autoincrementing column like an id column
    func testAutoIncrement() {
        try! dbconn.query("INSERT INTO test_queries (col_username) VALUES ('bob')")
        let newidRow1 = try! dbconn.query("SELECT LAST_INSERT_ID() AS newid")?.fetchRow()!
        let firstid = newidRow1!["newid"] as! Int64

        try! dbconn.query("INSERT INTO test_queries (col_username) VALUES ('fred')")
        let newidRow2 = try! dbconn.query("SELECT LAST_INSERT_ID() AS newid")?.fetchRow()!
        let secondid = newidRow2!["newid"] as! Int64

        assert(firstid != secondid)
    }
}
