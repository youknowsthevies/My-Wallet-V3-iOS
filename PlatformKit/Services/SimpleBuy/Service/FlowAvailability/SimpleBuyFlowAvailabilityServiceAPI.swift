//
//  SimpleBuyFlowAvailabilityServiceAPI.swift
//  PlatformKit
//
//  Created by Paulo on 10/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyFlowAvailabilityServiceAPI: AnyObject {
    /// Indicates that Simple Buy Flow is enabled for the current user.
    /// It may be because the User is elegible for Simple Buy or
    /// because another condtions is satisfied.
    var isSimpleBuyFlowAvailable: Observable<Bool> { get }
    
    /// Indicates that the current Fiat Currency is supported by Simple Buy remotely.
    func isFiatCurrencySupportedRemote(currency: FiatCurrency) -> Single<Bool>
    
    /// Indicates that the current Fiat Currency is supported by Simple Buy locally.
    func isFiatCurrencySupportedLocal(currency: FiatCurrency) -> Single<Bool>
}
