//
//  Client.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 07.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation

#if os(watchOS)
let osName = "watchOS"
#elseif os(OSX)
let osName = "macOS"
#elseif os(iOS)
let osName = "iOS"
#elseif os(tvOS)
let osName = "tvOS"
#endif

enum APIError: Error, LocalizedError {
    case urlSerializationError(String)
    case apiResponseError(HTTPURLResponse, Data?)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .urlSerializationError(let url): return NSLocalizedString("Error during decoding the url: \(url)", comment: "Error for the developer.")
        case .apiResponseError(let response, let body):

            let text: String
            if let body = body, let decodedText = String(data: body, encoding: .utf8) {
                text = "Response body: \(decodedText)"
            } else {
                text = "Response Body is not textual or empty"
            }

            switch response.statusCode {
            // Known case first
            case 400:
                return NSLocalizedString("Object of type missingParam. \(text)", comment: "Error for the developer. (Fromm RTS spec)")
            case 401:
                return NSLocalizedString("Object of type tokenError. \(text)", comment: "Error for the developer. (Fromm RTS spec)")
            case 403:
                return NSLocalizedString("Object of type quotaViolation. \(text)", comment: "Error for the developer. (Fromm RTS spec)")
            case 405:
                return NSLocalizedString("Object of type methodNotAllowed. \(text)", comment: "Error for the developer. (Fromm RTS spec)")
            case 404:
                return NSLocalizedString("Object of type unknownResource. \(text)", comment: "Error for the developer. (Fromm RTS spec)")
            default:
                return NSLocalizedString("Non RTS Error Code: \(response.statusCode). \(text)", comment: "Error for the developer.")
            }


        case .decodingError(let error): return NSLocalizedString("Error during JSON decoding: \(error)", comment: "Error for the developer.")
        }
    }
}

final class APIGetTokenOperation: RTSOperation, OAuthClientDelegate {

    let client: OAuthClient

    init(client: OAuthClient) {
        self.client = client
        super.init()
        name = "net.yageek.APIGetTokenOperation"
    }

    override func start() {
        isExecuting = true

        guard !isCancelled else {
            self.finish()
            return
        }

        // First check if if we have the token already
        if let token = client.token, !token.hasExpired {
            self.finish()
            return
        }

        client.delegate = self
        client.retrieveToken()
    }

    override var isAsynchronous: Bool {
        return true
    }

    // MARK: OAuthClientDelegate
    func oauthClient(client: OAuthClient, didRetrievedToken token: AccessToken) {
        self.finish()
    }

    func oauthClient(client: OAuthClient, didFailedToRetrieveToken error: Error) {
        print("Can not retrieve the token: \(error)")
        self.finish()
    }
}

// MARK: Operations
final class APIRequestOperation<Response: Decodable>: RTSOperation {

    let request: URLConvertible
    var token: AccessToken?
    let successBlock: (Response) -> Void
    let errorBlock: (Error) -> Void
    let session: URLSession
    let decoder: JSONDecoder
    let processInfo = ProcessInfo()

    var currentTask: URLSessionTask?

    init(session: URLSession = .shared, request: URLConvertible, success: @escaping (Response) -> Void, error: @escaping(Error) -> Void) {
        self.request = request
        self.successBlock = success
        self.errorBlock = error
        self.session = session
        self.decoder = JSONDecoder()
        super.init()
        self.name = "net.yageek.RTSwift.APIRequestOperation"
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

        guard let token = token else {
            print("No token has been provided :( Can not go on")
            self.finish()
            return
        }

        let baseURL = request.baseHost.appendingPathComponent(request.path)
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.queryItems = request.components.map { value in
            return URLQueryItem(name: value.key, value: value.value)
        }

        guard let url = components?.url else {
            print("Wrong API specification for request: \(request)")
            errorBlock(APIError.urlSerializationError(request.baseHost.absoluteString))
            finish()
            return
        }

        #if DEBUG
            print("Start request for: \(url)")
        #endif

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("gzip", forHTTPHeaderField: "gzip")

        let userAgent = "RTSSwift (\(osName) \(processInfo.operatingSystemVersionString))"

        urlRequest.setValue(userAgent, forHTTPHeaderField: "UserAgent")
        if request.securityEnabled {
            urlRequest.setValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")
        }

        let task = session.dataTask(with: urlRequest) { [unowned self] (data, response, error) in
            self.didDownloadData(data: data, response: response as? HTTPURLResponse, error: error)
        }

        currentTask = task
        task.resume()
    }

    private func didDownloadData(data: Data?, response: HTTPURLResponse?, error: Error? ) {
        guard !isCancelled else {
            self.finish()
            return
        }

        if let error = error {
            self.errorBlock(error)
            finish()
        } else if let response = response {

            guard let nonEmptyData = data, isResponseValid(response: response) else {
                self.errorBlock(APIError.apiResponseError(response, data))
                self.finish()
                return
            }

            do {
                let object = try decoder.decode(Response.self, from: nonEmptyData)
                self.successBlock(object)
            } catch let error {
                print("Error during decoding of \(Response.self): \(error)")
                self.errorBlock(APIError.decodingError(error))
                finish()
            }
        }
    }

    func isResponseValid(response: HTTPURLResponse) -> Bool {

        switch response.statusCode {
        case 200, 201:
            return true
        default:
            return false
        }
    }
    override func cancel() {
        super.cancel()
        currentTask?.cancel()
    }
}


// MARK: APIClient
class APIClient {

    let oauth: OAuthClient

    let requestQueue: OperationQueue = {
        let queue = OperationQueue()
        return queue
    }()

    let completionQueue: DispatchQueue

    init(key: String, secret: String, completionQueue: DispatchQueue? = nil) {
        self.oauth = OAuthClient(key: key, secret: secret)
        self.completionQueue = completionQueue ?? DispatchQueue.main
    }

    func performRequest<Response: Decodable>(request: URLConvertible, success: @escaping(Response) -> Void, error: @escaping(Error) -> Void) {
        let getToken = APIGetTokenOperation(client: oauth)
        let request = APIRequestOperation<Response>(request: request, success: success, error: error)

        let inject = BlockOperation { [unowned getToken, unowned request] in
            request.token = getToken.client.token
        }

        inject.addDependency(getToken)
        request.addDependency(inject)
        requestQueue.addOperations([request, getToken, inject], waitUntilFinished: false)

    }
}