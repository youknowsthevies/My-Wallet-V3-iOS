//
//  SendAuxiliaryView.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class SendAuxililaryViewInteractor {

    /// Streams reset to max events
    public var resetToMaxAmount: Observable<Void> {
        resetToMaxAmountRelay.asObservable()
    }
    
    let availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI

    let resetToMaxAmountRelay = PublishRelay<Void>()

    @available(*, deprecated, message: "Use `init(currencyType:coincore:)` method instead which uses the Coincore API")
    public init(balanceProvider: BalanceProviding, currencyType: CurrencyType) {
        availableBalanceContentViewInteractor = AvailableBalanceContentViewInteractor(
            balanceProvider: balanceProvider,
            currencyType: currencyType
        )
    }

    public init(currencyType: CurrencyType,
                coincore: Coincore = resolve()) {
        availableBalanceContentViewInteractor = AvailableBalanceContentInteractor(
            currencyType: currencyType,
            coincore: coincore
        )
    }
}
