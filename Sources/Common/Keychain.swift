//
//  Keychain.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 07.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation
import Security

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

class KeychainWrapper {

    func getToken() -> AccessToken {
    }

    func saveToken(token: AccessToken) {

    }
}
