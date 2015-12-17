//
//  TypesTestCase.swift
//  swiftmysql
//
//  Created by Steve Tibbett on 2015-12-12.
//  Copyright © 2015 Fall Day Software Inc. All rights reserved.
//

import XCTest

// Test that Swift types are being converted into mysql types and back as expected

class TypesTestCase: XCTestCase {

    let dbconn = MySQLConnection()
    
    // A table that contains a variety of types we want to test
    let dropTableSQL = "DROP TABLE IF EXISTS test_types"
    
    let createTypesTableSQL = "CREATE  TABLE `test`.`test_types` (" +
    "`col_autoinc` BIGINT NOT NULL AUTO_INCREMENT ," +
    "`col_int` INT NULL ," +
    "`col_bigint` BIGINT NULL ," +
    "`col_varchar64` VARCHAR(64) NULL ," +
    "`col_datetime` DATETIME NULL ," +
    "`col_blob` BLOB NULL ," +
    "`col_varchar64_nullable` VARCHAR(45) NULL ," +
    "`col_int_nullable` VARCHAR(45) NULL ," +
    "`col_text` TEXT NULL ," +
    "`col_varchar64_unique` VARCHAR(64) NULL ," +
    "PRIMARY KEY (`col_autoinc`) ," +
    "UNIQUE INDEX `col_varchar64_unique_UNIQUE` (`col_varchar64_unique` ASC) )"

    // Remove and re-create the test_types table
    override func setUp() {
        super.setUp()

        try! dbconn.connect(TestEnvironment.testhost, user: TestEnvironment.testuser, password: TestEnvironment.testpass, database: TestEnvironment.testdb)

        try! dbconn.query(dropTableSQL)
        try! dbconn.query(createTypesTableSQL)
    }
    
    func testVarchar64() {
        let testString = Array(count: 8, repeatedValue: "Hello123").joinWithSeparator("")
        assert(testString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 64)
        
        try! dbconn.query("INSERT INTO test_types (col_varchar64) VALUES (?)", params: [testString])
        let result = try! dbconn.query("SELECT col_varchar64 FROM test_types")
        assert(result != nil)
        let row = try! result?.fetchRow()!
        assert(row != nil)
        if let row = row {
            assert(row["col_varchar64"] as! String == testString)
        }
    }
    
    func testBigInt() {
        let testInt:Int64 = 42
        try! dbconn.query("INSERT INTO test_types (col_bigint) VALUES (?)", params: [Int(testInt)])
        let result = try! dbconn.query("SELECT col_bigint FROM test_types")
        assert(result != nil)
        let row = try! result?.fetchRow()!
        assert(row != nil)
        if let row = row {
            assert(row["col_bigint"] as! Int64 == testInt)
        }
    }
    
    func testDate() {
        let testDate = NSDate()
        try! dbconn.query("INSERT INTO test_types (col_datetime) VALUES (?)", params: [testDate])
        let result = try! dbconn.query("SELECT col_datetime FROM test_types")
        assert(result != nil)
        let row = try! result?.fetchRow()!
        assert(row != nil)
        if let row = row {
            let retrievedDate = row["col_datetime"] as! NSDate
            let interval = NSCalendar.currentCalendar().components([NSCalendarUnit.Second], fromDate: testDate, toDate: retrievedDate, options: NSCalendarOptions())
            assert(interval.second == 0)
        }
    }
}
