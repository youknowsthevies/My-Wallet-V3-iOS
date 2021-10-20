// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable all

import CasePaths
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

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
    public var cgFloat: CGFloat { CGFloat(self) }
}

extension BinaryFloatingPoint {
    public var cgFloat: CGFloat { CGFloat(self) }
}

extension BinaryInteger {

    public var pt: Length { .pt(cgFloat) }

    public var vw: Length { .vw(cgFloat) }
    public var vh: Length { .vh(cgFloat) }
    public var vmin: Length { .vmin(cgFloat) }
    public var vmax: Length { .vmax(cgFloat) }

    public var pw: Length { .pw(cgFloat) }
    public var ph: Length { .ph(cgFloat) }
    public var pmin: Length { .pmin(cgFloat) }
    public var pmax: Length { .pmax(cgFloat) }
}

extension BinaryFloatingPoint {

    public var pt: Length { .pt(cgFloat) }

    public var vw: Length { .vw(cgFloat) }
    public var vh: Length { .vh(cgFloat) }
    public var vmin: Length { .vmin(cgFloat) }
    public var vmax: Length { .vmax(cgFloat) }

    public var pw: Length { .pw(cgFloat) }
    public var ph: Length { .ph(cgFloat) }
    public var pmin: Length { .pmin(cgFloat) }
    public var pmax: Length { .pmax(cgFloat) }
}

extension CGRect {

    @inlinable public static var screen: CGRect {
        #if canImport(UIKit)
        UIScreen.main.bounds
        #elseif canImport(AppKit)
        NSScreen.main?.frame ?? .zero
        #endif
    }
}

extension CGSize {
    @inlinable public var min: CGFloat { Swift.min(width, height) }
    @inlinable public var max: CGFloat { Swift.max(width, height) }
}

extension Length {

    @inlinable public func `in`(_ proxy: GeometryProxy, coordinateSpace: CoordinateSpace = .local) -> CGFloat {
        `in`(parent: proxy.frame(in: coordinateSpace), screen: .screen)
    }

    @inlinable public func `in`(_ frame: CGRect) -> CGFloat {
        `in`(parent: frame, screen: frame)
    }

    @inlinable public func `in`(parent: CGRect, screen: CGRect = .screen) -> CGFloat {
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

public protocol ComputeLength {
    associatedtype ComputedValue
    func `in`(parent: CGRect, screen: CGRect) -> ComputedValue
}

extension ComputeLength {

    @inlinable public func `in`(_ geometry: GeometryProxy, coordinateSpace: CoordinateSpace) -> ComputedValue {
        `in`(parent: geometry.frame(in: coordinateSpace), screen: .screen)
    }

    @inlinable public func `in`(_ geometry: GeometryProxy) -> ComputedValue {
        `in`(geometry, coordinateSpace: .local)
    }

    @inlinable public func `in`(_ coordinateSpace: CoordinateSpace) -> (_ geometry: GeometryProxy) -> ComputedValue {
        { `in`($0, coordinateSpace: coordinateSpace) }
    }

    @inlinable public func `in`(_ frame: CGRect) -> ComputedValue {
        `in`(parent: frame, screen: frame)
    }
}

extension Length: ComputeLength {}
extension Size: ComputeLength {}

extension View {

    public func padding(
        _ length: Length,
        in frame: CGRect? = nil
    ) -> some View {
        padding(length.in(parent: frame ?? .screen))
    }

    public func padding(
        _ edges: Edge.Set = .all,
        _ length: Length,
        in frame: CGRect? = nil
    ) -> some View {
        padding(edges, length.in(parent: frame ?? .screen))
    }

    public func frame(
        width: Length,
        alignment: Alignment = .center,
        in frame: CGRect? = nil
    ) -> some View {
        self.frame(
            width: width.in(parent: frame ?? .screen),
            alignment: alignment
        )
    }

    public func frame(
        height: Length,
        alignment: Alignment = .center,
        in frame: CGRect? = nil
    ) -> some View {
        self.frame(
            height: height.in(parent: frame ?? .screen),
            alignment: alignment
        )
    }

    public func frame(
        width: Length,
        height: Length,
        alignment: Alignment = .center,
        in frame: CGRect? = nil
    ) -> some View {
        let frame = frame ?? .screen
        return self.frame(
            width: width.in(parent: frame),
            height: height.in(parent: frame),
            alignment: alignment
        )
    }

    public func frame(
        minWidth: Length? = nil,
        idealWidth: Length? = nil,
        maxWidth: Length? = nil,
        minHeight: Length? = nil,
        idealHeight: Length? = nil,
        maxHeight: Length? = nil,
        alignment: Alignment = .center,
        in frame: CGRect? = nil
    ) -> some View {
        let frame = frame ?? .screen
        return self.frame(
            minWidth: minWidth?.in(parent: frame),
            idealWidth: idealWidth?.in(parent: frame),
            maxWidth: maxWidth?.in(parent: frame),
            minHeight: minHeight?.in(parent: frame),
            idealHeight: idealHeight?.in(parent: frame),
            maxHeight: maxHeight?.in(parent: frame),
            alignment: alignment
        )
    }

    public func offset(
        _ size: Size,
        in frame: CGRect? = nil
    ) -> some View {
        offset(x: size.width, y: size.height, in: frame)
    }

    public func offset(
        x: Length,
        in frame: CGRect? = nil
    ) -> some View {
        offset(x: x.in(parent: frame ?? .screen))
    }

    public func offset(
        y: Length,
        in frame: CGRect? = nil
    ) -> some View {
        offset(y: y.in(parent: frame ?? .screen))
    }

    public func offset(
        x: Length,
        y: Length,
        in frame: CGRect? = nil
    ) -> some View {
        let parent = frame ?? .screen
        return offset(
            x: x.in(parent: parent),
            y: y.in(parent: parent)
        )
    }
}
