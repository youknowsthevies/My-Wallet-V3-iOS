//
//  ObservableType+ValueCalculationState.swift
//  PlatformKit
//
//  Created by Daniel Huri on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

extension ObservableType {
    public func mapCalculationState<Value, TargetValue>(_ map: @escaping (Value) -> TargetValue) -> Observable<ValueCalculationState<TargetValue>> where Element == ValueCalculationState<Value> {
        self.map { $0.mapValue(map) }
    }
}
