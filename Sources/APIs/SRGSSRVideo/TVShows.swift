//
//  TVShows.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 07.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension SRGSSRVideo {
    // TVShows
    public enum tvShows: URLConvertible {

        var securityEnabled: Bool { return true }

        case byAlphabetical(bu: BusinessUnit, filter: Character, pageSize: Int?, next: String?)
        case searchShowList(bu: BusinessUnit, query: String, pageSize: Int?, next: String?)
        case tvShow(bu: BusinessUnit, ID: String)

        var baseHost: URL { return PublicMetadataAPI }
        var path: String {
            switch self {
            case .byAlphabetical:
                return "/tv_shows/alphabetical"
            case let .tvShow(bu: _, ID: ID):
                return "/tv_shows/\(ID)"
            case .searchShowList:
                return "/tv_shows/"
            }
        }

        var components: [String: String?] {
            switch self {
            case let .byAlphabetical(bu: bu, filter: filter, pageSize: page, next: next):
                return fullParamsFrom(params: ["bu": bu.rawValue, "characterFilter": "\(filter)"], pageSize: page, next: next)
            case let .tvShow(bu: bu, _):
                return ["bu": bu.rawValue]
            case let .searchShowList(bu: bu, query: query, pageSize: page, next: next):
                return fullParamsFrom(params: ["bu": bu.rawValue,  "q": query,], pageSize: page, next: next)
            }
        }
    }
}


// MARK: - Request objects
extension SRGSSRVideo {

    public struct TVShow: Decodable {
        let id: String
        let vendor: String
        let transmission: String
        let urn: String
        let title: String
        let imageUrl: URL

        let url: URL?
        let description: String?
        let imageTitle: String?
        let bannerImageUrl: URL?
        let primaryChannelId: String?
        let numberOfEpisodes: Int?
    }

    public struct TVShowsAlphabeticalResultTrait: APIListResultTrait {
        public typealias ResponseObject = TVShow
        public static var listNameKey: String { return "showList" }
    }

    public struct TVShowsSearchResultTrait: APIListResultTrait {
        public typealias ResponseObject = TVShow
        public static var listNameKey: String { return "searchResultListShow" }
    }

    public typealias TVShowsAlphabeticalResult = APIResultList<TVShowsAlphabeticalResultTrait>

    public class TVShowsSearchResult: APIResultList<TVShowsSearchResultTrait> {
        let total: Int
        let searchTerm: String

        enum CountableKeys: CodingKey {
            case total
            case searchTerm
        }

        public required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CountableKeys.self)
            total = try values.decode(Int.self, forKey: .total)
            searchTerm = try values.decode(String.self, forKey: .searchTerm)
            try super.init(from: decoder)
        }
    }
}
