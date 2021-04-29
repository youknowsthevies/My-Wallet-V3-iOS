// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class AvailableBalanceContentInteractor: ContentLabelViewInteractorAPI {

    public let contentCalculationState: Observable<ValueCalculationState<String>>

    public init(currencyType: CurrencyType,
                coincore: Coincore) {

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

    init(account: BlockchainAccount,
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        contentCalculationState = fiatCurrencyService
            .fiatCurrencyObservable
            .flatMap { fiatCurrency -> Observable<MoneyValue> in
                account.fiatBalance(fiatCurrency: fiatCurrency).asObservable()
            }
            .map { .value($0.toDisplayString(includeSymbol: true)) }
            .share(replay: 1, scope: .whileConnected)
    }

    init(account: Observable<BlockchainAccount>,
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        contentCalculationState = fiatCurrencyService
            .fiatCurrencyObservable
            .flatMap { fiatCurrency -> Observable<MoneyValue> in
                account.flatMap { account in
                    account.fiatBalance(fiatCurrency: fiatCurrency)
                }
            }
            .map { .value($0.toDisplayString(includeSymbol: true)) }
            .share(replay: 1, scope: .whileConnected)
    }
}
