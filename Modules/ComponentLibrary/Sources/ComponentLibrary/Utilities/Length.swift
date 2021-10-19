// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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

    @usableFromInline internal static var mainScreenBounds: CGRect {
        #if canImport(UIKit)
        UIScreen.main.bounds
        #elseif canImport(AppKit)
        NSScreen.main?.frame ?? .zero
        #endif
    }
}

extension CGSize {
    @usableFromInline var min: CGFloat { Swift.min(width, height) }
    @usableFromInline var max: CGFloat { Swift.max(width, height) }
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

public protocol ComputedLength {
    associatedtype ComputedValue
    func `in`(parent: CGRect, screen: CGRect) -> ComputedValue
}

extension ComputedLength {

    @inlinable public func `in`(_ geometry: GeometryProxy, coordinateSpace: CoordinateSpace = .local) -> ComputedValue {
        `in`(parent: geometry.frame(in: coordinateSpace), screen: .mainScreenBounds)
    }

    @inlinable public func `in`(_ frame: CGRect) -> ComputedValue {
        `in`(parent: frame, screen: frame)
    }
}

extension Length: ComputedLength {}
extension Size: ComputedLength {}

// Generate the below with [gyb](https://nshipster.com/swift-gyb/) until we have variadic generics
extension View {

    public func compute<A: ComputedLength>(
        _ a: A,
        to binding: Binding<A.ComputedValue>
    ) -> some View {
        modifier(
            LengthViewModifier(a: a) { a in
                binding.wrappedValue = a
            }
        )
    }

    public func compute<A: ComputedLength>(
        _ a: A,
        _ yield: @escaping (A.ComputedValue) -> Void
    ) -> some View {
        modifier(
            LengthViewModifier(a: a, yield: yield)
        )
    }

    public func compute<A: ComputedLength, B: ComputedLength>(
        _ a: A,
        _ b: B,
        _ yield: @escaping (A.ComputedValue, B.ComputedValue) -> Void
    ) -> some View {
        modifier(
            LengthViewModifier2(a: a, b: b, yield: yield)
        )
    }

    public func compute<A: ComputedLength, B: ComputedLength, C: ComputedLength>(
        _ a: A,
        _ b: B,
        _ c: C,
        _ yield: @escaping (A.ComputedValue, B.ComputedValue, C.ComputedValue) -> Void
    ) -> some View {
        modifier(
            LengthViewModifier3(a: a, b: b, c: c, yield: yield)
        )
    }

    public func compute<A: ComputedLength, B: ComputedLength, C: ComputedLength, D: ComputedLength>(
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D,
        _ yield: @escaping (A.ComputedValue, B.ComputedValue, C.ComputedValue, D.ComputedValue) -> Void
    ) -> some View {
        modifier(
            LengthViewModifier4(a: a, b: b, c: c, d: d, yield: yield)
        )
    }
}

struct LengthViewModifier<A: ComputedLength>: ViewModifier {

    var a: A

    var yield: (A.ComputedValue) -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    yield(a.in(geometry))
                }
            }
        )
    }
}

struct LengthViewModifier2<A: ComputedLength, B: ComputedLength>: ViewModifier {

    var a: A
    var b: B

    var yield: (A.ComputedValue, B.ComputedValue) -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    yield(a.in(geometry), b.in(geometry))
                }
            }
        )
    }
}

struct LengthViewModifier3<A: ComputedLength, B: ComputedLength, C: ComputedLength>: ViewModifier {

    var a: A
    var b: B
    var c: C

    var yield: (A.ComputedValue, B.ComputedValue, C.ComputedValue) -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    yield(a.in(geometry), b.in(geometry), c.in(geometry))
                }
            }
        )
    }
}

struct LengthViewModifier4<A: ComputedLength, B: ComputedLength, C: ComputedLength, D: ComputedLength>: ViewModifier {

    var a: A
    var b: B
    var c: C
    var d: D

    var yield: (A.ComputedValue, B.ComputedValue, C.ComputedValue, D.ComputedValue) -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    yield(a.in(geometry), b.in(geometry), c.in(geometry), d.in(geometry))
                }
            }
        )
    }
}
