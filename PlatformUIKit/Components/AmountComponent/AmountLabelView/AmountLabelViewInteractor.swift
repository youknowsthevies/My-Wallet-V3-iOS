//
//  AmountLabelViewInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 05/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import PlatformKit

public final class AmountLabelViewInteractor {
    
    var currency: Observable<Currency> {
        currencyRelay
            .asObservable()
            .distinctUntilChanged { $0.code == $1.code }
    }
    
    // MARK: - Injected
    
    public let currencyRelay: BehaviorRelay<Currency>    
    public let stateRelay = BehaviorRelay<ValidationState>(value: .valid)
    
    /// Streams the state of the view model
    public var state: Observable<ValidationState> {
        stateRelay.asObservable()
    }
    
    public init(currency: Currency) {
        currencyRelay = BehaviorRelay(value: currency)
    }
}
