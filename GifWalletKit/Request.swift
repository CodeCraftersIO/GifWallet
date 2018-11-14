//
//  Request.swift
//  GifWalletKit
//
//  Created by Jordi Serra i Font on 14/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Foundation

public struct Request<ResponseType> {
    let endpoint: Endpoint
    let environment: Environment
}
