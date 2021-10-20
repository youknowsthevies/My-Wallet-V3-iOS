// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Comparable {

    @inlinable public func clamped(to range: ClosedRange<Self>) -> Self {
        (self...self).clamped(to: range).lowerBound
    }
}

@inlinable public func min<T, U: Comparable>(_ a: T, _ b: T, by: (T) -> U) -> T {
    by(a) < by(b) ? a : b
}

@inlinable public func max<T, U: Comparable>(_ a: T, _ b: T, by: (T) -> U) -> T {
    by(a) >= by(b) ? a : b
}
