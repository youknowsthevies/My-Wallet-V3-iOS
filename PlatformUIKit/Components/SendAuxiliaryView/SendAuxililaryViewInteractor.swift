//
//  SendAuxiliaryView.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit

public final class SendAuxililaryViewInteractor {

    /// Streams reset to max events
    public var resetToMaxAmount: Observable<Void> {
        resetToMaxAmountRelay.asObservable()
    }
    
    let availableBalanceContentViewInteractor: AvailableBalanceContentViewInteractor

    let resetToMaxAmountRelay = PublishRelay<Void>()
    
    public init(balanceProvider: BalanceProviding, currencyType: CurrencyType) {
        availableBalanceContentViewInteractor = AvailableBalanceContentViewInteractor(
            balanceProvider: balanceProvider,
            currencyType: currencyType
        )
    }
}
