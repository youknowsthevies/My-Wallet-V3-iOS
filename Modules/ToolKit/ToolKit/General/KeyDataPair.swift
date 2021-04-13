//
//  KeyDataPair.swift
//  ToolKit
//
//  Created by Daniel Huri on 20/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A construct that can be used as `key`-`data` pair.
public struct KeyDataPair<Key: Hashable, Element> {
    
    /// The key is hashable type of data
    public let key: Key
    
    /// The data is a non-constrained element
    public let data: Element
    
    public init(key: Key, data: Element) {
        self.key = key
        self.data = data
    }
}
