//
//  URNGetStreamOperation.swift
//  RTSwift-iOS
//
//  Created by Yannick Heinrich on 13.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import UIKit

final class URNGetStreamOperation: RTSOperation {

    private var streamURL: URL?

    let urn: String
    let session: URLSession
    let queue: OperationQueue
    let successBlock: (URL) -> Void
    let errorBlock: (Error) -> Void

    init(session: URLSession = .shared, URN: String, queue: OperationQueue, success: @escaping (URL) -> Void, error: @escaping(Error) -> Void) {
        self.urn = URN
        self.session = session
        self.queue = queue
        self.successBlock = success
        self.errorBlock = error

        super.init()
    }
    override var isAsynchronous: Bool {
        return true
    }

    override func start() {
        isExecuting = true

    
        let request = URN.getStreamInfos(URN: urn)
        let op = APIRequestOperation<URNResponse>(session: session, request: request, success: { [unowned self] (response) in

            guard let resourceListURL = response.chapterList.first?.resourceList.first?.url else {
                self.errorBlock(APIError.unknownError)
                self.finish()
                return
            }

            var pathsToken = resourceListURL.pathComponents[1..<4]
            pathsToken.append("*")

            let request = URN.getAkamaiToken(path: "/\(pathsToken.joined(separator: "/"))")
            let requestOp = APIRequestOperation<URNToken>(session: self.session, request: request, success: { (token) in

                let mediaURL = URL(string:"\(resourceListURL.absoluteString)?\(token.token.authparams)")!
                self.successBlock(mediaURL)

                self.finish()
            }, error: { (error) in
                print("Error during token download: \(error)")
                self.errorBlock(APIError.unknownError)
                self.finish()
            })

            self.queue.addOperation(requestOp)
        }) { (error) in
            print("Error during URN response download: \(error.localizedDescription)")
        }

        queue.addOperation(op)
    }
}
