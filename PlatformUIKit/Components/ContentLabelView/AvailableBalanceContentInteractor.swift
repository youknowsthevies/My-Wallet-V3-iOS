//
//  ContentLabelInteractor.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 15/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class AvailableBalanceContentInteractor: ContentLabelViewInteractorAPI {

    public let contentCalculationState: Observable<ValueCalculationState<String>>

    private let coincore: Coincore
    private let currencyType: CurrencyType

    public init(currencyType: CurrencyType,
                coincore: Coincore) {
        self.currencyType = currencyType
        self.coincore = coincore

        let balance = coincore.allAccounts
            .compactMap { group in
                group.accounts.first { $0.currencyType == currencyType }
            }
            .asObservable()
            .flatMap { account -> Single<MoneyValue> in
                account.balance
            }

        contentCalculationState = balance
            .map { .value($0.toDisplayString(includeSymbol: true)) }
            .share(replay: 1, scope: .whileConnected)
    }
}
