// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

/// A type that represents a payment method as a `BlockchainAccount`.
public struct PaymentMethodAccount: FiatAccount {

    public let paymentMethodType: PaymentMethodType
    public let paymentMethod: PaymentMethod

    public init(
        paymentMethodType: PaymentMethodType,
        paymentMethod: PaymentMethod
    ) {
        self.paymentMethodType = paymentMethodType
        self.paymentMethod = paymentMethod
    }

    public let isDefault: Bool = false

    public var activity: Single<[ActivityItemEvent]> {
        .just([]) // no activity to report
    }

    public var fiatCurrency: FiatCurrency {
        guard let fiatCurrency = paymentMethodType.currency.fiatCurrency else {
            impossible("Payment Method Accounts should always be denominated in fiat.")
        }
        return fiatCurrency
    }

    public var canWithdrawFunds: Single<Bool> {
        .just(false)
    }

    public var identifier: AnyHashable {
        paymentMethodType.id
    }

    public var label: String {
        paymentMethodType.label
    }

    public var isFunded: Single<Bool> {
        .just(true)
    }

    public var balance: Single<MoneyValue> {
        .just(paymentMethodType.balance)
    }

    public var actions: Single<AvailableActions> {
        .just([.buy])
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        .just(action == .buy)
    }
}
