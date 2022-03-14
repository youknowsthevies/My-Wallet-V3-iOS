// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Collection {

    public func filter<T>(_ type: T.Type) -> [T] {
        compactMap { $0 as? T }
    }
}

extension BinaryInteger {

    @inlinable public func of<T>(_ value: @autoclosure () -> T) -> [T] {
        Array(repeating: value(), count: i)
    }

    @inlinable public func of<T>(_ value: () -> T) -> [T] {
        Array(repeating: value(), count: i)
    }
}

extension Collection where Element: Equatable {

    public func sorted(like other: [Element]) -> [Element] {
        sorted { a, b -> Bool in
            guard let first = other.firstIndex(of: a) else { return false }
            guard let second = other.firstIndex(of: b) else { return true }
            return first < second
        }
    }
}
