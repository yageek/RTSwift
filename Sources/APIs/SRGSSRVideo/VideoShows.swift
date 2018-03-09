//
//  VideoShows.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 07.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation

// MARK: Endpoints
extension SRGSSRVideo {
    public enum videoShows: URLConvertible {

        case mostClicked(bu: BusinessUnit, topicID: String?, pageSize: Int?, next: String?)
        case recommended(bu: BusinessUnit, videoID: String, pageSize: Int?, next: String?)
        case expiringSoon(bu: BusinessUnit, pageSize: Int?, next: String?)
        case editorialRecommendation(bu: BusinessUnit, pageSize: Int?, next: String?)
        case trending(bu: BusinessUnit, onlyEpisodes: Bool?, maxCountEditorPicks: Int?, pageSize: Int?, next: String?)
        case mediaComposition(bu: BusinessUnit, videoID: String)
        case searchVideoList(bu: BusinessUnit, query: String, pageSize: Int?, next: String?)

        var securityEnabled: Bool { return true }
        var baseHost: URL { return PublicMetadataAPI }

        var path: String {
            switch self {
            case .mostClicked:
                return "/most_clicked"
            case let .recommended(bu: _, videoID: ID, pageSize: _, next: _):
                return "/\(ID)/recommended"
            case .expiringSoon:
                return "/expiring_soon"
            case .editorialRecommendation:
                return "/editorial_recomendation"
            case .trending:
                return "/trending_picks"
            case let .mediaComposition(bu: _, videoID: videoID):
                return "/\(videoID)/mediaComposition"
            case .searchVideoList:
                return "/search"
            }
        }

        var components: [String : String?] {
            switch self {
            case let .mostClicked(bu: bu, topicID: topicID, pageSize: pageSize, next: next):
                return fullParamsFrom(params: ["bu": bu.rawValue, "topicID": topicID], pageSize: pageSize, next: next)
            case let .recommended(bu: bu, videoID: _,  pageSize: pageSize, next: next):
                return fullParamsFrom(params: ["bu": bu.rawValue], pageSize: pageSize, next: next)
            case let .expiringSoon(bu: bu, pageSize: pageSize, next: next):
                return fullParamsFrom(params: ["bu": bu.rawValue], pageSize: pageSize, next: next)
            case let .editorialRecommendation(bu: bu, pageSize: pageSize, next: next):
                return fullParamsFrom(params: ["bu": bu.rawValue], pageSize: pageSize, next: next)
            case let .trending(bu: bu, onlyEpisodes: onlyEpisodes, maxCountEditorPicks: maxCountEditorPicks, pageSize: pageSize, next: next):
                var params: [String: String?] = ["bu": bu.rawValue]
                if let val = maxCountEditorPicks {
                    params["maxCountEditorPicks"] = "\(val)"
                }
                if let onlyEpisodes = onlyEpisodes {
                    params["onlyEpisodes"] = "\(onlyEpisodes)"
                }
                return fullParamsFrom(params: params, pageSize: pageSize, next: next)
            case let .mediaComposition(bu: bu, videoID: _):
                return ["bu": bu.rawValue]
            case let .searchVideoList(bu: bu, query: query, pageSize: pageSize, next: next):
                return fullParamsFrom(params: ["bu": bu.rawValue, "query": query], pageSize: pageSize, next: next)
            }
        }
    }
}


extension SRGSSRVideo {


    public struct VideoShowsListTrait: APIListResultTrait {
        public typealias ResponseObject = VideoShow
        public static var listNameKey: String{
            return "mediaList"
        }
    }

    public typealias VideoShowsList = APIResultList<VideoShowsListTrait>

    public struct VideoShow: Decodable {
        public let id: String
        public let mediaType: String
        public let vendor: String
        public let urn: String
        public let title: String

        public let description: String?
        public let imageUrl: URL
        public let type: String
        public let date: String
        public let duration: Int
        public let validFrom: String
        public let playableAbroad: Bool
        public let show: TVShow
        public let episode: Episode
    }

    public struct Episode: Decodable {
        public let id: String
        public let title: String
        public let description: String?
        public let publishedDate: String?
        public let imageUrl: URL
    }
}
