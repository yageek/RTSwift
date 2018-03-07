//
//  URL.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 06.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation

protocol URLConvertible {
    var securityEnabled: Bool { get }
    var baseHost: URL { get }
    var path: String { get }
    var components: [String: String?] { get }
}

