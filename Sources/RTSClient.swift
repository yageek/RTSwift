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
        client.performRequest(request: SRGSSRVideo.tvShows.searchShowList(bu: .rts, query: "russie", pageSize: nil, next: nil), success: success, error: error)
    }

    public func searchTVShowsAlphabetical(bu: BusinessUnit, filter: Character, pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.TVShowsAlphabeticalResult) -> Void, error: @escaping (Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.tvShows.byAlphabetical(bu: bu, filter: filter, pageSize: pageSize, next: next), success: success, error: error)
    }

    public func getTVShow(bu: BusinessUnit, ID: String, success: @escaping(SRGSSRVideo.TVShow) -> Void, error: @escaping (Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.tvShows.tvShow(bu: bu, ID: ID), success: success, error: error)
    }

    // MARK: - VideoShows
    public func getEditorialVideoShows(pageSize: Int? = nil, next: String? = nil, success: @escaping (SRGSSRVideo.VideoShowsList) -> Void, error: @escaping(Error) -> Void) {
        client.performRequest(request: SRGSSRVideo.videoShows.editorialRecommendation(pageSize: pageSize, next: next), success: success, error: error)
    }
}
