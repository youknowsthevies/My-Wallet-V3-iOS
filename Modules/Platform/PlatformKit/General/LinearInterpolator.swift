//
//  LinearInterpolator.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import ToolKit

public final class LinearInterpolator {
    /// Formula：Y = ( ( X - X1 )( Y2 - Y1) / ( X2 - X1) ) + Y1
    /// X1, Y1 = first value, X2, Y2 = second value, X = target value, Y = result
    public static func interpolate(x: Array<BigInt>, y: Array<BigInt>, xi: BigInt) -> BigInt {
        let zero = BigInt.zero
        precondition(x.count == y.count)
        precondition(x.count == 2)
        guard let firstX = x.first else { return zero }
        guard let lastX = x.last else { return zero }
        guard let firstY = y.first else { return zero }
        guard let lastY = y.last else { return zero }
        precondition(xi >= firstX && xi <= lastX)
        return (((xi - firstX) * (lastY - firstY) / (lastX - firstX)) + firstY)
    }
}
