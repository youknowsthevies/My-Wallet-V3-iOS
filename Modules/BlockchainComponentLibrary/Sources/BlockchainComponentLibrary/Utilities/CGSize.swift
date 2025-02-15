// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CoreGraphics

// swiftlint:disable line_length

extension CGSize {
    @inlinable public static func + (l: Self, r: CGFloat) -> Self { l.map { $0 + r } }
    @inlinable public static func - (l: Self, r: CGFloat) -> Self { l.map { $0 - r } }
    @inlinable public static func * (l: Self, r: CGFloat) -> Self { l.map { $0 * r } }
    @inlinable public static func / (l: Self, r: CGFloat) -> Self { l.map { $0 / r } }
}

extension CGSize {
    @inlinable public static func += (l: inout Self, r: CGFloat) { l = l + r }
    @inlinable public static func -= (l: inout Self, r: CGFloat) { l = l - r }
    @inlinable public static func *= (l: inout Self, r: CGFloat) { l = l * r }
    @inlinable public static func /= (l: inout Self, r: CGFloat) { l = l / r }
}

extension CGSize {
    @inlinable public static func + (l: Self, r: Self) -> Self { self.init(width: l.width + r.width, height: l.height + r.height) }
    @inlinable public static func - (l: Self, r: Self) -> Self { self.init(width: l.width - r.width, height: l.height - r.height) }
    @inlinable public static func * (l: Self, r: Self) -> Self { self.init(width: l.width * r.width, height: l.height * r.height) }
    @inlinable public static func / (l: Self, r: Self) -> Self { self.init(width: l.width / r.width, height: l.height / r.height) }
}

extension CGSize {
    @inlinable public static func += (l: inout Self, r: Self) { l = l + r }
    @inlinable public static func -= (l: inout Self, r: Self) { l = l - r }
    @inlinable public static func *= (l: inout Self, r: Self) { l = l * r }
    @inlinable public static func /= (l: inout Self, r: Self) { l = l / r }
}

extension CGSize {
    @inlinable public func map<T>(_ ƒ: (CGFloat) -> T) -> (T, T) { (ƒ(width), ƒ(height)) }
    @inlinable public func map(_ ƒ: (CGFloat) -> CGFloat) -> Self { Self(width: ƒ(width), height: ƒ(height)) }
}
