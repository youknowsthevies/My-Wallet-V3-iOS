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

public protocol SendAuxililaryViewInteractorAPI: AnyObject {
    var resetToMaxAmount: Observable<Void> { get }

    var availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI { get }

    var resetToMaxAmountRelay: PublishRelay<Void> { get }
}

public extension SendAuxililaryViewInteractorAPI {
    /// Streams reset to max events
    var resetToMaxAmount: Observable<Void> {
        resetToMaxAmountRelay.asObservable()
    }
}

public final class SendAuxililaryViewInteractor: SendAuxililaryViewInteractorAPI {

    public let availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI

    public let resetToMaxAmountRelay = PublishRelay<Void>()

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
