//
//  ValueCalculationState+Platform.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

/// Calculation state with an associated `MoneyValueBalancePairs`.
/// It represents the calculation state of the total balance.
public typealias MoneyBalancePairsCalculationState = ValueCalculationState<MoneyValueBalancePairs>

/// Calculation state with an associated `MoneyValuePair`
/// It represents the calculation state of base and quote amounts.
public typealias MoneyValuePairCalculationState = ValueCalculationState<MoneyValuePair>

/// Calculation state with an associated `FiatValue`
public typealias FiatValueCalculationState = ValueCalculationState<FiatValue>
