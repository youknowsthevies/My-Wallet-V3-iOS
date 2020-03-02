//
//  SimpleBuySuggestedAmountsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 29/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

// TODO: Handle `CryptoValue`
/// The calculation state of Simple Buy suggested fiat amounts to buy
public typealias SimpleBuySuggestedAmountsCalculationState = ValueCalculationState<[FiatValue]>

/// A simple buy suggested amounts API
public protocol SimpleBuySuggestedAmountsServiceAPI: class {
    
    /// Streams the suggested amounts
    var calculationState: Observable<SimpleBuySuggestedAmountsCalculationState> { get }
    
    /// Refresh, triggering a re-fetch of `SimpleBuySuggestedAmountsCalculationState`.
    /// Makes `calculationState` to stream an updated value
    func refresh()
}
