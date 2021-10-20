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

    @inlinable public func `in`(_ frame: CGRect) -> ComputedValue {
        `in`(parent: frame, screen: frame)
    }
}

extension Length: ComputeLength {}
extension Size: ComputeLength {}


struct LengthViewModifier<A: ComputeLength>: ViewModifier {

    var length: A
    var yield: (A.ComputedValue) -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    yield(length.in(geometry))
                }
            }
        )
    }
}

extension View {

    public func bind<A: ComputeLength>(
        _ a: A,
        to binding: Binding<A.ComputedValue>
    ) -> some View {
        return modifier(LengthViewModifier(a: a) { binding.wrappedValue = $0 })
    }

    public func length<A: ComputeLength>(
        _ a: A,
        _ yield: @escaping (A.ComputedValue) -> Void
    ) -> some View {
        modifier(LengthViewModifier(a: a, yield: yield))
    }
}

extension View {

    public func padding(_ length: Length) -> some View {
        withGeometry(length.in(_:)) { $0.padding($1) }
    }

    public func padding(_ edges: Edge.Set = .all, _ length: Length) -> some View {
        withGeometry(length.in(_:)) { $0.padding(edges, $1) }
    }

    public func frame(width: Length, alignment: Alignment = .center) -> some View {
        withGeometry(width.in(_:)) { $0.frame(width: $1, alignment: alignment) }
    }

    public func frame(height: Length, alignment: Alignment = .center) -> some View {
        withGeometry(height.in(_:)) { $0.frame(height: $1, alignment: alignment) }

    }

    public func frame(width: Length, height: Length, alignment: Alignment = .center) -> some View {
        withGeometry({ (width: width.in($0), height: height.in($0)) }) {
            $0.frame(width: $1.width, height: $1.height, alignment: alignment)
        }
    }

    public func frame(
        minWidth: Length? = nil,
        idealWidth: Length? = nil,
        maxWidth: Length? = nil,
        minHeight: Length? = nil,
        idealHeight: Length? = nil,
        maxHeight: Length? = nil,
        alignment: Alignment = .center
    ) -> some View {
        withGeometry(
            {
                (
                    minWidth: minWidth?.in($0),
                    idealWidth: idealWidth?.in($0),
                    maxWidth: maxWidth?.in($0),
                    minHeight: minHeight?.in($0),
                    idealHeight: idealHeight?.in($0),
                    maxHeight: maxHeight?.in($0)
                )
            }
        ) {
            $0.frame(
                minWidth: $1.minWidth,
                idealWidth: $1.idealWidth,
                maxWidth: $1.maxWidth,
                minHeight: $1.minHeight,
                idealHeight: $1.idealHeight,
                maxHeight: $1.maxHeight,
                alignment: alignment
            )
        }
    }

    public func offset(_ size: Size) -> some View {
        offset(x: size.width, y: size.height)
    }

    public func offset(x: Length) -> some View {
        withGeometry(x.in(_:)) { $0.offset(x: $1) }
    }

    public func offset(y: Length) -> some View {
        withGeometry(y.in(_:)) { $0.offset(y: $1) }
    }

    public func offset(x: Length, y: Length) -> some View {
        withGeometry({ (x: x.in($0), y: y.in($0) }) { $0.offset(x: $1.x, y: $1.y) }
    }
}
