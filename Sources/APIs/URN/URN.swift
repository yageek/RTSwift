//
//  URN.swift
//  RTSwift-iOS
//
//  Created by Yannick Heinrich on 13.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation

public enum URN: URLConvertible {

    static let AKAMAI_URL = URL(string: "http://tp.srgssr.ch/")!
    static let URN_URL = URL(string: "http://il.srgssr.ch/integrationlayer/2.0")!

    var securityEnabled: Bool {
        return false
    }

    var baseHost: URL {
        switch self {
        case .getAkamaiToken:
            return URN.AKAMAI_URL
        case .getStreamInfos:
            return URN.URN_URL
        }
    }

    var path: String {
        switch self {
        case let .getStreamInfos(URN: urn):
            return "mediaComposition/byUrn/\(urn).json"
        case .getAkamaiToken:
            return "akahd/token"

        }
    }

    var components: [String : String?] {
        switch self {
        case .getStreamInfos:
            return ["onlyChapters":"true", "vector":"portalplay"]
        case let .getAkamaiToken(path: path):
            return ["acl":path]
        }
    }

    case getStreamInfos(URN: String)
    case getAkamaiToken(path: String)

}

struct URNToken: Codable {
    struct Token: Codable {
        let window: Int
        let acl: String
        let authparams: String
    }
    let token: Token
}

