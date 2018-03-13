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

    let client = RTSClient(key: "CONSUMER", secret: "SECRET")

    func testToken() {

        let expect = expectation(description: "Wait for call")
//        client.searchTVShows(bu: .rts, query: "russie", success: { (result: SRGSSRVideo.TVShowsSearchResult) in
//            print("List of TVShows:")
//            for element in result.list {
//                print("ID: \(element.id)")
//                print("Title: \(element.title)")
//                print("Transmission: \(element.transmission)")
//                print("URN: \(element.urn)")
//
//            }
//            expect.fulfill()
//        }) { (error) in
//            print("Error: \(error.localizedDescription)")
//            XCTFail()
//        }

        client.getURN(URN: "urn:rts:video:9394670", success: { (url) in

        }) { (error) in

        }
        wait(for: [expect], timeout: 10.0)
    }

}
