//
//  URL+Conveniences.swift
//  PlatformKit
//
//  Created by AlexM on 5/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension URL {
    
    /// Returns the query arguments of this URL as a key-value pair
    public var queryArgs: [String: String] {
        query?.queryArgs ?? [:]
    }
}
