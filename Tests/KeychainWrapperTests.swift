//
//  KeychainWrapperTests.swift
//  RTSwiftTests-iOS
//
//  Created by Yannick Heinrich on 08.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import XCTest
@testable import RTSwift

class KeychainWrapperTests: XCTestCase {

    let wrapper = KeychainWrapper()
    override func setUp() {
        super.setUp()
        try! wrapper.deleteToken()
    }
    
    func testSaveGet() {

        // No token should exist before the test
        XCTAssertThrowsError(try wrapper.getToken())

        // Creation of a token should succeed
        let name = "some_token_string"
        let date = Date()

        let accessToken = AccessToken(token: name, expires: date)
        XCTAssertNoThrow(try wrapper.saveToken(token: accessToken))

        // Reading the token should equals the original one
        var token: AccessToken!
        XCTAssertNoThrow(token = try wrapper.getToken())
        XCTAssertEqual(token, accessToken)

        // Deleting the token should works
        XCTAssertNoThrow(try wrapper.deleteToken())

        // Reading the token should failed now with no data
        XCTAssertThrowsError(try wrapper.getToken(), "An error .noPassword should be thrown") { (error) in

            guard case KeychainError.noPassword = error else {
                XCTFail("invalid error received")
                return
            }
        }
    }

}
