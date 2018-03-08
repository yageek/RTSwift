//
//  OAuth.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 06.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation
/// See https://developer.srgssr.ch/content/quickstart-guide

public struct AccessTokenResponse: Decodable {
    let issueAt: Date
    let applicationName: String
    let scope: String
    let status: String
    let apiProductList: String
    let expires: Date
    let developerEmail: String
    let tokenType: String
    let clientID: String
    let accessToken: String
    let organisationName: String
    let refreshTokenExpires: Date
    let refreshCount: Int

    public enum CodingKeys: String, CodingKey {
        case issueAt = "issued_at"
        case applicationName = "application_name"
        case scope
        case status
        case apiProductList = "api_product_list"
        case expires = "expires_in"
        case developerEmail = "developer.email"
        case tokenType = "token_type"
        case clientID = "client_id"
        case accessToken = "access_token"
        case organisationName = "organization_name"
        case refreshTokenExpires = "refresh_token_expires_in"
        case refreshCount = "refresh_count"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let issuedAtRaw = try values.decode(String.self, forKey: .issueAt)
        guard let interval = TimeInterval(issuedAtRaw) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [AccessTokenResponse.CodingKeys.issueAt], debugDescription: "Value does not represent a time interval"))
        }

        issueAt = Date(timeIntervalSince1970: interval)

        applicationName = try values.decode(String.self, forKey: .applicationName)
        status = try values.decode(String.self, forKey: .status)
        apiProductList = try values.decode(String.self, forKey: .apiProductList)

        let expiresRaw = try values.decode(String.self, forKey: .expires)
        guard let expiresSecond = TimeInterval(expiresRaw) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [AccessTokenResponse.CodingKeys.expires], debugDescription: "Value does not represent a time interval"))
        }
        expires = Date(timeIntervalSinceNow: expiresSecond)

        developerEmail = try values.decode(String.self, forKey: .developerEmail)
        tokenType = try values.decode(String.self, forKey: .tokenType)
        clientID = try values.decode(String.self, forKey: .clientID)
        accessToken = try values.decode(String.self, forKey: .accessToken)
        organisationName = try values.decode(String.self, forKey: .organisationName)
        scope = try values.decode(String.self, forKey: .scope)
        
        let refreshTokenExpiresRaw = try values.decode(String.self, forKey: .refreshTokenExpires)
        guard let refreshExpires = TimeInterval(refreshTokenExpiresRaw) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [AccessTokenResponse.CodingKeys.refreshTokenExpires], debugDescription: "Value does not represent a time interval"))
        }
        refreshTokenExpires = Date(timeIntervalSinceNow: refreshExpires)

        let refreshCountRaw = try values.decode(String.self, forKey: .refreshCount)
        guard let refreshCountValue = Int(refreshCountRaw) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [AccessTokenResponse.CodingKeys.refreshCount], debugDescription: "Value does not represent an integer as a string"))
        }
        refreshCount = refreshCountValue

    }
}

public enum OAuthError: Error {
    case authenticationFailed(String)

}
// MARK: - Token Operations
final class OAuthRequestTokenOperation: RTSOperation {

    private var key: String
    private var secret: String

    var accessTokenTask: URLSessionTask?
    var getProtectedTokenTask: URLSessionTask?

    let successBlock: (AccessTokenResponse) -> Void
    let errorBlock: (Error) -> Void
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    init(key: String, secret: String, success: @escaping (AccessTokenResponse) -> Void, error: @escaping (Error) -> Void) {
        self.key = key
        self.secret = secret
        self.successBlock = success
        self.errorBlock = error

        super.init()
        name = "net.yageek.OAuthRequestTokenOperation"
    }

    override var isAsynchronous: Bool {
        return true
    }


    override func start() {
        isExecuting = true

        guard !isCancelled else {
            self.finish()
            return
        }

        let requestURL = URL(string: "https://api.srgssr.ch/oauth/v1/accesstoken?grant_type=client_credentials")!
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        let authenticationValue = "\(key):\(secret)".data(using: .ascii)!
        let base64Value = authenticationValue.base64EncodedString()
        request.addValue("Basic \(base64Value)", forHTTPHeaderField: "Authorization")

        accessTokenTask = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let cancelled = self?.isCancelled, !cancelled else { return }
            self?.didDownloadToken(data: data, response: response as? HTTPURLResponse, error: error)
        })
        accessTokenTask?.resume()
    }

    private func didDownloadToken(data: Data?, response: HTTPURLResponse?, error: Error?) {

        if let error = error {
            self.errorBlock(error)
            self.finish()
        } else if let response = response {

            guard response.statusCode == 200 else {
                print("Error: The API returned an HTTP Code")

                if let data = data {
                    print("Response: \(String(data: data, encoding: .utf8) ?? "<Empty>")")
                }
                errorBlock(OAuthError.authenticationFailed("HTTP ERROR CODE: \(response.statusCode)"))
                self.finish()
                return
            }

            guard let data = data else {
                print("Invalid Access Token")
                errorBlock(OAuthError.authenticationFailed("The provided token is empty"))
                self.finish()
                return
            }

            do {
                let token = try decoder.decode(AccessTokenResponse.self, from: data)
                self.successBlock(token)
                self.finish()
            } catch let error {
                print("Impossible to decode the response from the server: \(error)")
                self.errorBlock(error)
                self.finish()
            }
        }
    }

    override func cancel() {
        super.cancel()
        accessTokenTask?.cancel()
    }

}


// MARK: - Client
struct AccessToken: Codable, Equatable {
    let token: String
    let expires: Date

    var hasExpired: Bool {
        return Date().compare(expires) == .orderedAscending
    }
    
    static func ==(lhs: AccessToken, rhs: AccessToken) -> Bool {
        return lhs.token == rhs.token && lhs.expires == rhs.expires
    }
}

protocol OAuthClientDelegate: class {
    func oauthClient(client: OAuthClient, didRetrievedToken token: AccessToken)
    func oauthClient(client: OAuthClient, didFailedToRetrieveToken error: Error)
}


final class OAuthClient {

    private var key: String
    private var secret: String

    private var _token: AccessToken?
    var token: AccessToken? {
        get {

            var tok: AccessToken?
            lock.sync {
                tok = _token
            }
            return tok
        }
        set {
            lock.sync {
                _token = newValue
            }
        }
    }
    private var lock = PThreadMutex()

    weak var delegate: OAuthClientDelegate?

    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "net.yageek.RTSwift"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(key: String, secret: String, token: String? = nil) {
        self.key = key
        self.secret = secret
    }

    func retrieveToken() {
        let operation = OAuthRequestTokenOperation(key: key, secret: secret, success: { [unowned self] (response) in

            let token = AccessToken(token: response.accessToken, expires: response.expires)
            self.token = token
            self.delegate?.oauthClient(client: self, didRetrievedToken: token )

        }) {  [unowned self]  (error) in
            self.delegate?.oauthClient(client: self, didFailedToRetrieveToken: error)
        }
        queue.addOperation(operation)
    }

    func cancel() {
        queue.cancelAllOperations()
    }

}
