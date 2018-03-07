//
//  Concurrency.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 06.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation

class RTSOperation: Operation {
    var _isFinished: Bool = false
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }

        get {
            return _isFinished
        }
    }

    var _isExecuting: Bool = false

    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }

        get {
            return _isExecuting
        }
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}

