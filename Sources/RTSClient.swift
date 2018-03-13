//
//  RTSClient.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 07.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation

public class RTSClient {
    let client: APIClient

    public init(key: String, secret: String) {
        self.client = APIClient(key: key, secret: secret)
    }

    // MARK: - TVShows
    public func searchTVShows(bu: BusinessUnit, query: String, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.TVShowsSearchResult) -> Void, error: @escaping (Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.tvShows.searchShowList(bu: bu, query: query, pageSize: nil, next: nil), success: success, error: error)
    }

    public func searchTVShowsAlphabetical(bu: BusinessUnit, filter: Character, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.TVShowsAlphabeticalResult) -> Void, error: @escaping (Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.tvShows.byAlphabetical(bu: bu, filter: filter, pageSize: pageSize, next: next), success: success, error: error)
    }

    public func getTVShow(bu: BusinessUnit, ID: String, success: @escaping(SRGSSRVideo.TVShow) -> Void, error: @escaping (Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.tvShows.tvShow(bu: bu, ID: ID), success: success, error: error)
    }

    // MARK: - VideoShows
    public func getMostClickedVideosShows(bu: BusinessUnit, topicID: String? = nil, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.VideoShowsList) -> Void, error: @escaping(Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.videoShows.mostClicked(bu: bu, topicID: topicID, pageSize: pageSize, next: next), success: success, error: error)
    }

    public func getRecommendedVideosShows(bu: BusinessUnit, videoID: String, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.VideoShowsList) -> Void, error: @escaping(Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.videoShows.recommended(bu: bu, videoID: videoID, pageSize: pageSize, next: next), success: success, error: error)
    }

    public func getExpiringSoonVideosShows(bu: BusinessUnit, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.VideoShowsList) -> Void, error: @escaping(Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.videoShows.expiringSoon(bu: bu, pageSize: pageSize, next: next), success: success, error: error)
    }

    public func getEditorialRecommendationVideoShows(bu: BusinessUnit, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.VideoShowsList) -> Void, error: @escaping(Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.videoShows.editorialRecommendation(bu: bu, pageSize: pageSize, next: next), success: success, error: error)
    }

    public func getTrendingVideosShows(bu: BusinessUnit, onlyEpisodes: Bool? = nil, maxCountEditorPicks: Int? = nil, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.VideoShowsList) -> Void, error: @escaping(Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.videoShows.trending(bu: bu, onlyEpisodes: onlyEpisodes, maxCountEditorPicks: maxCountEditorPicks, pageSize: pageSize, next: next), success: success, error: error)
    }

    public func searchVideosShows(bu: BusinessUnit, query: String, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.VideoShowsList) -> Void, error: @escaping (Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.videoShows.searchVideoList(bu: bu, query: query, pageSize: nil, next: nil), success: success, error: error)
    }

    public func getURN(URN urn: String, success: @escaping (URL) -> Void, error: @escaping (Error) -> Void) {
        let op = URNGetStreamOperation(URN: urn, queue: client.requestQueue, success: success, error: error)
        client.performOperation(op: op)
    }
}
