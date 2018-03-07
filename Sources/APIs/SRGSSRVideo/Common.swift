//
//  Common.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 07.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation

// MARK: - Common API
public protocol APIListResultTrait {
    associatedtype ResponseObject: Decodable
    static var listNameKey: String { get }
}

public class APIResultList<Result: APIListResultTrait>: Decodable {

    let next: URL?
    let list: [Result.ResponseObject]

    public struct CodingKeys: CodingKey {
        public var intValue: Int?
        public var stringValue: String

        public init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
        public init?(stringValue: String) { self.stringValue = stringValue }
        static func makeKey(name: String) -> CodingKeys {
            return CodingKeys(stringValue: name)!
        }
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        next = try values.decodeIfPresent(URL.self, forKey: .makeKey(name: "next"))
        list = try values.decode(Array<Result.ResponseObject>.self, forKey: .makeKey(name: Result.listNameKey))
    }
}

func fullParamsFrom(params: [String: String?], pageSize: Int?, next: String?) ->  [String: String?] {
    var params = params

    if let page = pageSize {
        params["page"] = String(page)
    }
    if let next = next {
        params["next"] = next
    }

    return params
}

// MARK: - API constants
let PublicMetadataAPI: URL = URL(string: "https://api.srgssr.ch/videometadata/v2/")!

public enum BusinessUnit: String {
    case srf = "srf"
    case rtr = "rtr"
    case swi = "swi"
    case rsi = "rsi"
    case rts = "rts"
}

// MARK: - Endpoints
public struct SRGSSRVideo { }

