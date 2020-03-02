//
//  ValueCalculationState+Platform.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

/// Calculation state with an associated `AssetFiatCryptoBalancePairs`
public typealias AssetFiatCryptoBalanceCalculationState = ValueCalculationState<AssetFiatCryptoBalancePairs>

/// Calculation state with an associated `FiatCryptoPair`
public typealias FiatCryptoPairCalculationState = ValueCalculationState<FiatCryptoPair>

/// Calculation state with an associated `FiatValue`
public typealias FiatValueCalculationState = ValueCalculationState<FiatValue>
