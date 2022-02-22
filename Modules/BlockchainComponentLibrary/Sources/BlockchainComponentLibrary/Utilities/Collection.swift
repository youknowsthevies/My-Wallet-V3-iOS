// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftformat:disable redundantSelf

import Algorithms

extension Collection {
    @inlinable public var array: [Element] { Array(self) }
}

extension Collection {

    @inlinable public func min<T>(
        using keyPath: KeyPath<Element, T>,
        by areInIncreasingOrder: (T, T) throws -> Bool
    ) rethrows -> Element? where T: Comparable {
        try self.min(by: { try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }

    @inlinable public func max<T>(
        using keyPath: KeyPath<Element, T>,
        by areInIncreasingOrder: (T, T) throws -> Bool
    ) rethrows -> Element? where T: Comparable {
        try self.max(by: { try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }

    @inlinable public func minAndMax<T>(
        using keyPath: KeyPath<Element, T>,
        by areInIncreasingOrder: (T, T) throws -> Bool
    ) rethrows -> (min: Element, max: Element)? where T: Comparable {
        try minAndMax(by: { try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }
}
