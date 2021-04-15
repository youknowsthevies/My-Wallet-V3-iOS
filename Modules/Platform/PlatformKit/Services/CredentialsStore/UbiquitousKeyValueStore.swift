//
//  UbiquitousKeyValueStore.swift
//  PlatformKit
//
//  Created by Paulo on 23/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Interface for NSUbiquitousKeyValueStore
public protocol UbiquitousKeyValueStore {
    func set(_ aDictionary: [String : Any]?, forKey aKey: String)
    func dictionary(forKey aKey: String) -> [String : Any]?
    func synchronize() -> Bool
}

extension NSUbiquitousKeyValueStore: UbiquitousKeyValueStore { }
