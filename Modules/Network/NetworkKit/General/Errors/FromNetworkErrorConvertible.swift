//
//  FromNetworkErrorConvertible.swift
//  NetworkKit
//
//  Created by Jack Pooley on 03/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Higher level `Error` types should conform to this to enable mapping from `NetworkError` errors
public protocol FromNetworkErrorConvertible: Error, Decodable {
    
    static func from(_ networkError: NetworkError) -> Self
}
