// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxSwift
import ToolKit

/// An `AccountGroup` containing all accounts.
public final class AllAccountsGroup: AccountGroup {
    private typealias LocalizedString = LocalizationConstants.AccountGroup

    public let accounts: [SingleAccount]
    public let identifier: AnyHashable = "AllAccountsGroup"
    public let label: String = LocalizedString.allWallets
    let actions: AvailableActions = [.viewActivity]

    public var isFunded: Single<Bool> {
        if accounts.isEmpty {
            return .just(false)
        }
        return Single.zip(accounts.map(\.isFunded))
            .map { values -> Bool in
                !values.contains(false)
            }
    }

    public var requireSecondPassword: Single<Bool> {
        if accounts.isEmpty {
            return .just(false)
        }

        return Single.zip(accounts.map(\.requireSecondPassword))
            .map { values -> Bool in
                !values.contains(false)
            }
    }

    public var pendingBalance: Single<MoneyValue> {
        unimplemented()
    }

    public var balance: Single<MoneyValue> {
        if accounts.isEmpty {
            return .just(.zero(currency: currencyType))
        }
        let asset = self.currencyType
        return Single.zip(accounts.map(\.balance))
            .map { values -> MoneyValue in
                try values.reduce(MoneyValue.zero(currency: asset), +)
            }
    }

    public var actionableBalance: Single<MoneyValue> {
        unimplemented()
    }

    public var receiveAddress: Single<ReceiveAddress> {
        unimplemented()
    }

    public init(accounts: [SingleAccount]) {
        self.accounts = accounts
    }
}
