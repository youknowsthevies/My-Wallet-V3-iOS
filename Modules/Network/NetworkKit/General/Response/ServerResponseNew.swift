//
//  ServerResponseNew.swift
//  NetworkKit
//
//  Created by Jack Pooley on 25/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct ServerResponseNew {
    let payload: Data?
    let response: HTTPURLResponse
}

public struct ServerErrorResponseNew: Error {
    public let response: HTTPURLResponse
    public let payload: Data?
}
