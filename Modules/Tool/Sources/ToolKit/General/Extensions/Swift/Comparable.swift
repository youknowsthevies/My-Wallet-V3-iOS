// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Comparable {

    @inlinable public func clamped(to range: ClosedRange<Self>) -> Self {
        (self...self).clamped(to: range).lowerBound
    }
}

extension Comparable where Self: FloatingPoint {

    @inlinable public func clamped(to range: PartialRangeFrom<Self>) -> Self {
        (self...self).clamped(to: range.lowerBound...(.greatestFiniteMagnitude)).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        (self...self).clamped(to: -(.greatestFiniteMagnitude)...(range.upperBound - 1)).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeThrough<Self>) -> Self {
        (self...self).clamped(to: -(.greatestFiniteMagnitude)...range.upperBound).lowerBound
    }
}

@inlinable public func min<T, U: Comparable>(_ a: T, _ b: T, by: (T) -> U) -> T {
    by(a) < by(b) ? a : b
}

@inlinable public func max<T, U: Comparable>(_ a: T, _ b: T, by: (T) -> U) -> T {
    by(a) >= by(b) ? a : b
}
