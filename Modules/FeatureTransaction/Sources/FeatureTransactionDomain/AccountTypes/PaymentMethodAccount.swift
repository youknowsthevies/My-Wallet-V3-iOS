// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import ToolKit

// TODO: replace this with an AccountGroup

/// A type that represents a payment method as a `BlockchainAccount`.
public struct PaymentMethodAccount: FiatAccount {

    public let paymentMethod: PaymentMethod
    public let linkedAccount: FiatAccount?

    public var activity: Single<[ActivityItemEvent]> {
        .just([]) // no activity to report
    }

    public var fiatCurrency: FiatCurrency {
        paymentMethod.min.currency
    }

    public var canWithdrawFunds: Single<Bool> {
        .just(false)
    }

    public var isDefault: Bool {
        linkedAccount?.isDefault ?? false
    }

    public var identifier: AnyHashable {
        guard let linkedAccountIdentifier = linkedAccount?.identifier else {
            return AnyHashable(paymentMethod.type.rawType.rawValue)
        }
        return linkedAccountIdentifier
    }

    public var label: String {
        linkedAccount?.label ?? paymentMethod.type.rawType.rawValue
    }

    public var isFunded: Single<Bool> {
        .just(true)
    }

    public var balance: Single<MoneyValue> {
        .just(paymentMethod.max.moneyValue)
    }

    public var actions: Single<AvailableActions> {
        .just([.buy])
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        .just(action == .buy)
    }
}
