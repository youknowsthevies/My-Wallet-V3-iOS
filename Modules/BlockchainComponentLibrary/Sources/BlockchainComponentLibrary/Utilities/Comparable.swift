// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Comparable {

    @inlinable public func isBetween(_ this: Self, and that: Self) -> Bool {
        let (l, u) = this < that ? (this, that) : (that, this)
        return l <= self && self <= u
    }
}

extension BinaryInteger {

    @inlinable public func clamped(to range: Range<Self>) -> Self {
        (self...self).clamped(to: range.lowerBound...range.upperBound - 1).lowerBound
    }
}

extension Comparable {

    @inlinable public func clamped(to range: ClosedRange<Self>) -> Self {
        (self...self).clamped(to: range).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeFrom<Self>) -> Self {
        (self...self).clamped(to: range).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        (self..<self).clamped(to: range).lowerBound
    }

    @inlinable public func clamped(to range: PartialRangeThrough<Self>) -> Self {
        (self...self).clamped(to: range).lowerBound
    }
}

extension ClosedRange {
    public init(between: Bound, and: Bound) {
        self = between < and ? between...and : and...between
    }
}

extension ClosedRange {

    @inlinable public func clamped(to range: PartialRangeFrom<Bound>) -> Self {
        clamped(to: range.lowerBound...Swift.max(upperBound, range.lowerBound))
    }

    @inlinable public func clamped(to range: PartialRangeThrough<Bound>) -> Self {
        clamped(to: Swift.min(lowerBound, range.upperBound)...range.upperBound)
    }
}

extension Range {

    @inlinable public func clamped(to range: PartialRangeUpTo<Bound>) -> Self {
        clamped(to: Swift.min(lowerBound, range.upperBound)..<range.upperBound)
    }
}
