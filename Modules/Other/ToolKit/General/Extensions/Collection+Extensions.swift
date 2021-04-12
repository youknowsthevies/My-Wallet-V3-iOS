//
//  Collection+Extensions.swift
//  ToolKit
//
//  Created by Paulo on 06/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Collection {

    /// Allows safe indexing into this collection. If the provided index is within
    /// bounds, the item will be returned, otherwise, nil.
    public subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
