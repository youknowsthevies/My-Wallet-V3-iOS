//
//  ValueCalculationState+Map.swift
//  PlatformKit
//
//  Created by Daniel Huri on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension ValueCalculationState {
    public func mapValue<TargetValue>(_ map: (Value) -> TargetValue) -> ValueCalculationState<TargetValue> {
        switch self {
        case .calculating:
            return .calculating
        case .invalid(.empty):
            return .invalid(.empty)
        case .invalid(.valueCouldNotBeCalculated):
            return .invalid(.valueCouldNotBeCalculated)
        case .value(let value):
            return .value(map(value))
        }
    }
}
