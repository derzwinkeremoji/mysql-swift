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

    override func setUp() {
        super.setUp()
        
        try! dbconn.connect(TestEnvironment.testhost, user: TestEnvironment.testuser, password: TestEnvironment.testpass, database: TestEnvironment.testdb)
    }
    
    func testSimpleMath() {
        let result = try! dbconn.query("SELECT 2+2 AS SHOULD_BE_FOUR")
        assert(result != nil)
        let row = try! result!.fetchRow()
        assert(row != nil)
        assert(row!.keys.first == "SHOULD_BE_FOUR")
        assert(row!["SHOULD_BE_FOUR"] as! Int64 == 4)
    }

}
