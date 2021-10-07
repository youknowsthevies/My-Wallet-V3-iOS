// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CasePaths
import SwiftUI
import ToolKit

// https://developer.mozilla.org/en-US/docs/Web/CSS/length
public enum Length: Hashable {

    case pt(CGFloat)

    case vw(CGFloat)
    case vh(CGFloat)
    case vmin(CGFloat)
    case vmax(CGFloat)

    case pw(CGFloat)
    case ph(CGFloat)
    case pmin(CGFloat)
    case pmax(CGFloat)
}

extension Length: CustomStringConvertible {

    public var description: String {
        switch self {
        case .pt(let o):
            return "\(o)pt"
        case .vw(let o):
            return "\(o)vw"
        case .vh(let o):
            return "\(o)vh"
        case .vmin(let o):
            return "\(o)vmin"
        case .vmax(let o):
            return "\(o)vmax"
        case .pw(let o):
            return "\(o)pw"
        case .ph(let o):
            return "\(o)ph"
        case .pmin(let o):
            return "\(o)pmin"
        case .pmax(let o):
            return "\(o)pmax"
        }
    }
}

public struct Size: Hashable, Codable {

    public var width: Length
    public var height: Length

    public init(width: Length, height: Length) {
        self.width = width
        self.height = height
    }

    public init(length: Length) {
        width = length
        height = length
    }
}

extension BinaryInteger {

    public var pt: Length { .pt(cg) }

    public var vw: Length { .vw(cg) }
    public var vh: Length { .vh(cg) }
    public var vmin: Length { .vmin(cg) }
    public var vmax: Length { .vmax(cg) }

    public var pw: Length { .pw(cg) }
    public var ph: Length { .ph(cg) }
    public var pmin: Length { .pmin(cg) }
    public var pmax: Length { .pmax(cg) }
}

extension BinaryFloatingPoint {

    public var pt: Length { .pt(cg) }

    public var vw: Length { .vw(cg) }
    public var vh: Length { .vh(cg) }
    public var vmin: Length { .vmin(cg) }
    public var vmax: Length { .vmax(cg) }

    public var pw: Length { .pw(cg) }
    public var ph: Length { .ph(cg) }
    public var pmin: Length { .pmin(cg) }
    public var pmax: Length { .pmax(cg) }
}

extension CGRect {

    @usableFromInline internal static var mainScreenBounds: CGRect {
        #if canImport(UIKit)
        UIScreen.main.bounds
        #elseif canImport(AppKit)
        NSScreen.main.bounds
        #endif
    }
}

extension Length {

    @inlinable public func `in`(_ proxy: GeometryProxy, coordinateSpace: CoordinateSpace = .local) -> CGFloat {
        `in`(parent: proxy.frame(in: coordinateSpace), screen: .mainScreenBounds)
    }

    @inlinable public func `in`(_ frame: CGRect) -> CGFloat {
        `in`(parent: frame, screen: frame)
    }

    @inlinable public func `in`(parent: CGRect, screen: CGRect) -> CGFloat {
        switch self {
        case .pt(let o):
            return o

        case .vw(let o):
            return screen.width * o / 100
        case .vh(let o):
            return screen.height * o / 100
        case .vmin(let o):
            return screen.size.min * o / 100
        case .vmax(let o):
            return screen.size.max * o / 100

        case .pw(let o):
            return parent.width * o / 100
        case .ph(let o):
            return parent.height * o / 100
        case .pmin(let o):
            return parent.size.min * o / 100
        case .pmax(let o):
            return parent.size.max * o / 100
        }
    }
}

extension Size {

    public static var zero: Size = .init(length: 0.pt)
    public static var unit: Size = .init(length: 1.pt)

    @inlinable public func `in`(_ proxy: GeometryProxy, coordinateSpace: CoordinateSpace = .local) -> CGSize {
        CGSize(
            width: width.in(proxy, coordinateSpace: coordinateSpace),
            height: height.in(proxy, coordinateSpace: coordinateSpace)
        )
    }

    @inlinable public func `in`(_ frame: CGRect) -> CGSize {
        CGSize(
            width: width.in(frame),
            height: height.in(frame)
        )
    }

    @inlinable public func `in`(parent: CGRect, screen: CGRect) -> CGSize {
        CGSize(
            width: width.in(parent: parent, screen: screen),
            height: height.in(parent: parent, screen: screen)
        )
    }
}

extension Length: Codable {

    public enum Key: String, CodingKey {

        case pt

        case vw
        case vh
        case vmin
        case vmax

        case pw
        case ph
        case pmin
        case pmax
    }

    private static var __allCases: [Key: CasePath<Length, CGFloat>] = [
        Key.pt: /Length.pt,
        Key.vw: /Length.vw,
        Key.vh: /Length.vh,
        Key.vmin: /Length.vmin,
        Key.vmax: /Length.vmax,
        Key.pw: /Length.pw,
        Key.ph: /Length.ph,
        Key.pmin: /Length.pmin,
        Key.pmax: /Length.pmax
    ]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        for (key, casePath) in Self.__allCases {
            if let unit = try container.decodeIfPresent(CGFloat.self, forKey: key) {
                self = casePath.embed(unit)
                return
            }
        }
        throw DecodingError.valueNotFound(
            Length.self,
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "No length was found at codingPath '\(decoder.codingPath)'"
            )
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        for (key, casePath) in Self.__allCases {
            if let unit = casePath.extract(from: self) {
                try container.encode(unit, forKey: key)
                return
            }
        }
    }
}
