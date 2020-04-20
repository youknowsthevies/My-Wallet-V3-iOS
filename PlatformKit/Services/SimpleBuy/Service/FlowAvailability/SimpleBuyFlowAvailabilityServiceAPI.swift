//
//  SimpleBuyFlowAvailabilityServiceAPI.swift
//  PlatformKit
//
//  Created by Paulo on 10/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyFlowAvailabilityServiceAPI: AnyObject {

    /// Indicates that the current Fiat Currency is supported by Simple Buy locally.
    func isFiatCurrencySupportedLocal(currency: FiatCurrency) -> Single<Bool>
}
