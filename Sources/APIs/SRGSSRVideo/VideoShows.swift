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
        case editorialRecommendation(pageSize: Int?, next: String?)

        var securityEnabled: Bool { return true }

        var baseHost: URL { return PublicMetadataAPI }

        var path: String {
            switch self {
            case .editorialRecommendation:
                return "/editorial_recomendation"
            }
        }

        var components: [String : String?] {
            switch self {
            case let .editorialRecommendation(pageSize: pageSize, next: next):
                return fullParamsFrom(params: [:], pageSize: pageSize, next: next)
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
        let id: String
        let mediaType: String
        let vendor: String
        let urn: String
        let title: String

        let description: String
        let imageUrl: URL
        let type: String
        let date: Date
        let duration: Int
        let validTo: Date
        let playableAbroad: Bool
        let show: TVShow
        let episode: Episode
    }

    public struct Episode: Decodable {
        let id: String
        let title: String
        let description: String
        let publishedDate: Date
        let imageUrl: URL
    }
}
