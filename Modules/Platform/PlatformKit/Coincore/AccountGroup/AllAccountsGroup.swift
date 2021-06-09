// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxSwift
import ToolKit

/// An `AccountGroup` containing all accounts.
final class AllAccountsGroup: AccountGroup {
    private typealias LocalizedString = LocalizationConstants.AccountGroup

    let accounts: [SingleAccount]
    let id: String = "AllAccountsGroup"
    let label: String = LocalizedString.allWallets
    let actions: AvailableActions = [.viewActivity]

    var isFunded: Single<Bool> {
        if accounts.isEmpty {
            return .just(false)
        }
        return Single.zip(accounts.map(\.isFunded))
            .map { values -> Bool in
                !values.contains(false)
            }
    }

    var requireSecondPassword: Single<Bool> {
        if accounts.isEmpty {
            return .just(false)
        }

        return Single.zip(accounts.map(\.requireSecondPassword))
            .map { values -> Bool in
                !values.contains(false)
            }
    }

    var pendingBalance: Single<MoneyValue> {
        .error(AccountGroupError.noBalance)
    }

    var balance: Single<MoneyValue> {
        .error(AccountGroupError.noBalance)
    }

    var actionableBalance: Single<MoneyValue> {
        unimplemented()
    }

    var receiveAddress: Single<ReceiveAddress> {
        unimplemented()
    }

    init(accounts: [SingleAccount]) {
        self.accounts = accounts
    }

    func balancePair(fiatCurrency: FiatCurrency) -> Observable<MoneyValuePair> {
        unimplemented()
    }

    func fiatBalance(fiatCurrency: FiatCurrency) -> Observable<MoneyValue> {
        let balances: [Observable<MoneyValue>] = accounts
            .map { account in
                account
                    .fiatBalance(fiatCurrency: fiatCurrency)
            }
        return Observable.combineLatest(balances)
            .map { balances in
                try balances.reduce(MoneyValue.zero(currency: fiatCurrency), +)
            }
    }

}
