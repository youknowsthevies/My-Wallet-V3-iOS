//
//  SimpleBuySupportedPairsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

/// The calculation state of Simple Buy supported pairs
public typealias BuyCryptoSupportedPairsCalculationState = ValueCalculationState<SimpleBuySupportedPairs>

/// A simple buy possible pairs API
public protocol SimpleBuySupportedPairsInteractorServiceAPI: class {
    var valueObservable: Observable<SimpleBuySupportedPairs> { get }
    var valueSingle: Single<SimpleBuySupportedPairs> { get }
    func fetch() -> Observable<SimpleBuySupportedPairs>
}

public protocol SimpleBuySupportedPairsServiceAPI: class {
    
    /// Fetches `pairs` using the specified filter
    func fetchPairs(for option: SupportedPairsFilterOption) -> Single<SimpleBuySupportedPairs>
}
