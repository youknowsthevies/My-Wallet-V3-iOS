// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import ToolKit

// https://developer.mozilla.org/en-US/docs/Web/CSS/length
public enum Length {

    public typealias Unit = CGFloat

    case pt(Unit)

    case vw(Unit)
    case vh(Unit)
    case vmin(Unit)
    case vmax(Unit)

    case pw(Unit)
    case ph(Unit)
    case pmin(Unit)
    case pmax(Unit)
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

extension Length {

    public func `in`(_ proxy: GeometryProxy, coordinateSpace: CoordinateSpace = .local) -> CGFloat {
        `in`(parent: proxy.frame(in: coordinateSpace), screen: proxy.frame(in: .global))
    }

    public func `in`(_ frame: CGRect) -> CGFloat {
        `in`(parent: frame, screen: frame)
    }

    public func `in`(parent: CGRect, screen: CGRect) -> CGFloat {
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
