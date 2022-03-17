// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import Combine
import Foundation
import MoneyKit

public struct Account: Identifiable {

    public enum AccountType: String {
        case privateKey
        case trading
        case interest
        case exchange
    }

    public var id: AnyHashable

    public let name: String
    public let accountType: AccountType
    public let cryptoCurrency: CryptoCurrency
    public let fiatCurrency: FiatCurrency

    public let actionsPublisher: AnyPublisher<OrderedSet<Account.Action>, Error>
    public let cryptoBalancePublisher: AnyPublisher<MoneyValue, Never>
    public let fiatBalancePublisher: AnyPublisher<MoneyValue, Never>

    public init(
        id: AnyHashable,
        name: String,
        accountType: Account.AccountType,
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        actionsPublisher: AnyPublisher<OrderedSet<Account.Action>, Error>,
        cryptoBalancePublisher: AnyPublisher<MoneyValue, Never>,
        fiatBalancePublisher: AnyPublisher<MoneyValue, Never>
    ) {
        self.id = id
        self.name = name
        self.accountType = accountType
        self.cryptoCurrency = cryptoCurrency
        self.fiatCurrency = fiatCurrency
        self.actionsPublisher = actionsPublisher
        self.cryptoBalancePublisher = cryptoBalancePublisher
        self.fiatBalancePublisher = fiatBalancePublisher
    }
}

extension Account {

    public struct Snapshot: Hashable, Identifiable {

        public var id: AnyHashable

        public let name: String
        public let accountType: AccountType
        public let cryptoCurrency: CryptoCurrency
        public let fiatCurrency: FiatCurrency

        public let actions: OrderedSet<Account.Action>
        public let crypto: MoneyValue
        public let fiat: MoneyValue

        public init(
            id: AnyHashable,
            name: String,
            accountType: Account.AccountType,
            cryptoCurrency: CryptoCurrency,
            fiatCurrency: FiatCurrency,
            actions: OrderedSet<Account.Action>,
            crypto: MoneyValue,
            fiat: MoneyValue
        ) {
            self.id = id
            self.name = name
            self.accountType = accountType
            self.cryptoCurrency = cryptoCurrency
            self.fiatCurrency = fiatCurrency
            self.actions = actions
            self.crypto = crypto
            self.fiat = fiat
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public static func == (lhs: Account.Snapshot, rhs: Account.Snapshot) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension Account {

    public struct Action: Hashable, Identifiable {
        public var id: L
        public var title: String
        public var description: String
        public var icon: Icon
    }
}

extension Account.Action {

    public static let buy = Account.Action(
        id: blockchain.ux.asset.account.buy,
        title: "Buy",
        description: "Use Your Cash or Card",
        icon: .walletBuy
    )

    public static let sell = Account.Action(
        id: blockchain.ux.asset.account.sell,
        title: "Sell",
        description: "Convert Your Crypto to Cash",
        icon: .walletSell
    )

    public static let send = Account.Action(
        id: blockchain.ux.asset.account.send,
        title: "Send",
        description: "Transfer %@ to Other Wallets",
        icon: .walletSend
    )

    public static let receive = Account.Action(
        id: blockchain.ux.asset.account.receive,
        title: "Receive",
        description: "Receive %@ to your account",
        icon: .walletReceive
    )

    public static let swap = Account.Action(
        id: blockchain.ux.asset.account.swap,
        title: "Swap",
        description: "Exchange %@ for Another Crypto",
        icon: .walletSwap
    )

    public static let rewards = (
        withdraw: Account.Action(
            id: blockchain.ux.asset.account.rewards.withdraw,
            title: "Withdraw",
            description: "Withdraw %@ from Rewards Account",
            icon: .withdraw
        ),
        deposit: Account.Action(
            id: blockchain.ux.asset.account.rewards.deposit,
            title: "Deposit",
            description: "Add %@ to Rewards Account",
            icon: .deposit
        ),
        summary: Account.Action(
            id: blockchain.ux.asset.account.rewards.summary,
            title: "Summary",
            description: "View Accrued %@ Rewards",
            icon: .walletPercent
        )
    )

    public static let exchange = (
        withdraw: Account.Action(
            id: blockchain.ux.asset.account.exchange.withdraw,
            title: "Withdraw",
            description: "Withdraw %@ from Exchange",
            icon: .withdraw
        ),
        deposit: Account.Action(
            id: blockchain.ux.asset.account.exchange.deposit,
            title: "Deposit",
            description: "Add %@ to Exchange",
            icon: .deposit
        )
    )

    public static let activity = Account.Action(
        id: blockchain.ux.asset.account.activity,
        title: "Activity",
        description: "View all transactions",
        icon: .activity
    )
}

extension Collection where Element == Account {

    public var snapshot: AnyPublisher<[Account.Snapshot], Never> {
        map { account -> AnyPublisher<Account.Snapshot, Never> in
            account.cryptoBalancePublisher
                .combineLatest(account.fiatBalancePublisher, account.actionsPublisher.replaceError(with: []))
                .map { crypto, fiat, actions in
                    Account.Snapshot(
                        id: account.id,
                        name: account.name,
                        accountType: account.accountType,
                        cryptoCurrency: account.cryptoCurrency,
                        fiatCurrency: account.fiatCurrency,
                        actions: actions,
                        crypto: crypto,
                        fiat: fiat
                    )
                }
                .eraseToAnyPublisher()
        }
        .zip()
        .eraseToAnyPublisher()
    }
}

extension Collection where Element == Account.Snapshot {

    public var cryptoBalance: MoneyValue? {
        guard let currency = first?.cryptoCurrency else { return nil }
        return try? map(\.crypto)
            .reduce(MoneyValue.zero(currency: currency), +)
    }

    public var fiatBalance: MoneyValue? {
        guard let currency = first?.fiatCurrency else { return nil }
        return try? map(\.fiat)
            .reduce(MoneyValue.zero(currency: currency), +)
    }

    public var hasPositiveBalanceForSelling: Bool {
        filter { account in
            [.privateKey, .trading].contains(account.accountType)
        }.fiatBalance?.isPositive ?? false
    }
}
