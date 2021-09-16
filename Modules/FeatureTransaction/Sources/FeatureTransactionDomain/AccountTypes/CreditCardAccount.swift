// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

/// A `BlockchainAccount` that represents a credit or debit card.
/// Instances of this class are intented to be used as a source for a Buy transaction.
public struct CreditCardAccount: FiatAccount {

    public let isDefault: Bool = false

    private let cardData: CardData

    public init(cardData: CardData) {
        self.cardData = cardData
    }

    public var identifier: AnyHashable {
        cardData.identifier
    }

    public var label: String {
        "\(cardData.label) \(cardData.displaySuffix)"
    }

    public var fiatCurrency: FiatCurrency {
        cardData.currency
    }

    public var canWithdrawFunds: Single<Bool> {
        .just(false)
    }

    public var isFunded: Single<Bool> {
        .just(true)
    }

    public var balance: Single<MoneyValue> {
        .just(cardData.topLimit.moneyValue)
    }

    public var actions: Single<AvailableActions> {
        .just([.buy])
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        .just(action == .buy)
    }

    public var activity: Single<[ActivityItemEvent]> {
        .just([])
    }
}
