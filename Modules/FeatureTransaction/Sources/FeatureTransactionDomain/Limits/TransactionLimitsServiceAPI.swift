// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import NabuNetworkError
import PlatformKit

public enum TransactionLimitsServiceError: Error {
    case network(NabuNetworkError)
}

/// Use this service to fetch the limits for any kind of trade the logged-in user can perform.
/// This service is meant to be used by `TransactionEngine`s to fetch limits data that can be used to create or update `PendingTransaction`s.
public protocol TransactionLimitsServiceAPI {

    func fetchLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> AnyPublisher<TransactionLimits, TransactionLimitsServiceError>
}

final class TransactionLimitsService: TransactionLimitsServiceAPI {

    private let repository: TransactionLimitsRepositoryAPI

    init(repository: TransactionLimitsRepositoryAPI) {
        self.repository = repository
    }

    func fetchLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> AnyPublisher<TransactionLimits, TransactionLimitsServiceError> {
        repository
            .fetchCrossBorderLimits(
                source: LimitsAccount(
                    currency: paymentMethod.fiatCurrency.currencyType,
                    accountType: paymentMethod.type.isFunds ? .custodial : .nonCustodial
                ),
                destination: LimitsAccount(
                    currency: targetCurrency,
                    accountType: .custodial
                ),
                limitsCurrency: limitsCurrency
            )
            .map { crossBorderLimits -> TransactionLimits in
                TransactionLimits(crossBorderLimits: crossBorderLimits, paymentMethod: paymentMethod)
            }
            .mapError(TransactionLimitsServiceError.network)
            .eraseToAnyPublisher()
    }
}

extension TransactionLimits {

    init(crossBorderLimits: CrossBorderLimits, paymentMethod: PaymentMethod) {
        let infinity = MoneyValue(amount: BigInt(Int.max), currency: crossBorderLimits.currency)
        let maxCrossBorderCurrentLimit = crossBorderLimits.currentLimits?.available ?? infinity
        let maxCrossBorderDailyLimit = crossBorderLimits.currentLimits?.daily?.limit ?? infinity
        let maxCrossBorderAnnualLimit = crossBorderLimits.currentLimits?.yearly?.limit ?? infinity
        let maxCombinedLimit = try? MoneyValue.min(paymentMethod.max.moneyValue, maxCrossBorderCurrentLimit)
        self.init(
            minimum: paymentMethod.min.moneyValue,
            maximum: maxCombinedLimit ?? paymentMethod.max.moneyValue,
            maximumDaily: maxCrossBorderDailyLimit,
            maximumAnnual: maxCrossBorderAnnualLimit,
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade
        )
    }
}
