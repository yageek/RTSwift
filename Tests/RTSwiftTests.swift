//
//  RTSwiftTests.swift
//  RTSwiftTests
//
//  Created by Yannick Heinrich on 06.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import XCTest
@testable import RTSwift

class RTSwiftTests: XCTestCase {

    let client = RTSClient(key: "KEY", secret: "SECRET")

    func testToken() {

        let expect = expectation(description: "Wait for call")
        client.searchTVShows(bu: .rts, query: "russie", success: { (result: SRGSSRVideo.TVShowsSearchResult) in
            print("List of TVShows:")
            for element in result.list {
                print("ID: \(element.id)")
                print("Title: \(element.title)")
                print("Transmission: \(element.transmission)")
                
            }
            expect.fulfill()
        }) { (error) in
            print("Error: \(error.localizedDescription)")
            XCTFail()
        }

        wait(for: [expect], timeout: 10.0)
    }

}
