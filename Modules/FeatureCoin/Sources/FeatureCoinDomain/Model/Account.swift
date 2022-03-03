// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit

public struct Account: Equatable, Identifiable {

    public enum AccountType {
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

    public let cryptoBalancePublisher: AnyPublisher<MoneyValue, Never>
    public let fiatBalancePublisher: AnyPublisher<MoneyValue, Never>

    public init(
        id: AnyHashable,
        name: String,
        accountType: Account.AccountType,
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        cryptoBalancePublisher: AnyPublisher<MoneyValue, Never>,
        fiatBalancePublisher: AnyPublisher<MoneyValue, Never>
    ) {
        self.id = id
        self.name = name
        self.accountType = accountType
        self.cryptoCurrency = cryptoCurrency
        self.fiatCurrency = fiatCurrency
        self.cryptoBalancePublisher = cryptoBalancePublisher
        self.fiatBalancePublisher = fiatBalancePublisher
    }

    public static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
}

extension Collection where Element == Account {
    public var totalCryptoBalancePublisher: AnyPublisher<MoneyValue, Never> {
        map(\.cryptoBalancePublisher)
            .zip()
            .compactMap {
                if let currency = $0.first?.currency {
                    return try? $0.reduce(.zero(currency: currency), +)
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    public var totalFiatBalancePublisher: AnyPublisher<MoneyValue, Never> {
        map(\.fiatBalancePublisher)
            .zip()
            .compactMap {
                if let currency = $0.first?.currency {
                    return try? $0.reduce(.zero(currency: currency), +)
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    public var hasPositiveBalanceForSelling: AnyPublisher<Bool, Never> {
        filter { [.privateKey, .trading].contains($0.accountType) }
            .totalFiatBalancePublisher
            .map(\.isPositive)
            .eraseToAnyPublisher()
    }
}
