// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Collections
import Combine
import Foundation
import MoneyKit
import SwiftUI

public struct AccountSnapshot: Identifiable, Equatable {

    public var id: AnyHashable

    public let name: String
    public let cryptoCurrency: CryptoCurrency?
    public let fiatCurrency: FiatCurrency

    public let crypto: MoneyValue
    public let fiat: MoneyValue

    public let image: Image
    public let backgroundColor: Color

    public init(
        id: AnyHashable,
        name: String,
        cryptoCurrency: CryptoCurrency?,
        fiatCurrency: FiatCurrency,
        crypto: MoneyValue,
        fiat: MoneyValue,
        image: Image,
        backgroundColor: Color = .clear
    ) {
        self.id = id
        self.name = name
        self.cryptoCurrency = cryptoCurrency
        self.fiatCurrency = fiatCurrency
        self.crypto = crypto
        self.fiat = fiat
        self.image = image
        self.backgroundColor = backgroundColor
    }

    public static func == (lhs: AccountSnapshot, rhs: AccountSnapshot) -> Bool {
        lhs.id == rhs.id
    }
}

public struct AccountBalancePair: Codable, Equatable {

    public let accountId: String

    public let balance: Money

    public init(
        accountId: String,
        balance: Money
    ) {
        self.accountId = accountId
        self.balance = balance
    }
}

public struct AccountCurrency: Codable, Equatable {

    public let accountCurrency: String

    public init(
        accountCurrency: String
    ) {
        self.accountCurrency = accountCurrency
    }
}

extension AccountSnapshot {

    public var iconWidth: CGFloat {
        backgroundColor == .clear ? 24 : 24
    }

    public var cornerRadius: CGFloat {
        backgroundColor == .clear ? 0 : 4
    }
}
