//
//  ErrorResponseConvertible.swift
//  NetworkKit
//
//  Created by Jack Pooley on 03/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Higher level `Error` types should conform to this to enable mapping from `NetworkCommunicatorErrorNew` errors
public protocol ErrorResponseConvertible: Error, Decodable {
    
    static func from(_ communicatorError: NetworkCommunicatorError) -> Self
}
