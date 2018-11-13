//
//  Environment.swift
//  GifWalletKit
//
//  Created by Jordi Serra i Font on 13/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Foundation

public protocol Environment {
    var baseURL: URL { get }
    var shouldAllowInsecureConnections: Bool { get }
}

public extension Environment {
    var shouldAllowInsecureConnections: Bool {
        return false
    }
}
