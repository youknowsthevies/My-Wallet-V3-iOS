// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import NabuNetworkError
import PlatformKit
import ToolKit

public typealias TransactionLimitsServicePublisher = AnyPublisher<TransactionLimits, TransactionLimitsServiceError>

public enum TransactionLimitsServiceError: Error {
    case network(NabuNetworkError)
    case other(Error)
}

/// Use this service to fetch the limits for any kind of trade the logged-in user can perform.
/// This service is meant to be used by `TransactionEngine`s to fetch limits data that can be used to create or update `PendingTransaction`s.
public protocol TransactionLimitsServiceAPI {

    func fetchLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> TransactionLimitsServicePublisher
}

final class TransactionLimitsService: TransactionLimitsServiceAPI {

    private let repository: TransactionLimitsRepositoryAPI
    private let conversionService: CurrencyConversionServiceAPI
    private let featureFlagService: FeatureFlagsServiceAPI

    init(
        repository: TransactionLimitsRepositoryAPI,
        conversionService: CurrencyConversionServiceAPI,
        featureFlagService: FeatureFlagsServiceAPI
    ) {
        self.repository = repository
        self.conversionService = conversionService
        self.featureFlagService = featureFlagService
    }

    func fetchLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> TransactionLimitsServicePublisher {
        featureFlagService.isEnabled(.local(.newTxFlowLimitsUIEnabled))
            .flatMap { [unowned self] newLimitsEnabled -> TransactionLimitsServicePublisher in
                guard newLimitsEnabled else {
                    return self.deriveLimits(from: paymentMethod, inputCurrency: limitsCurrency)
                }
                return self.fetchCrossBorderLimits(
                    for: paymentMethod,
                    targetCurrency: targetCurrency,
                    limitsCurrency: limitsCurrency
                )
            }
            .eraseToAnyPublisher()
    }

    private func deriveLimits(
        from paymentMethod: PaymentMethod,
        inputCurrency: CurrencyType
    ) -> TransactionLimitsServicePublisher {
        let paymentMethodLimits = TransactionLimits(
            minimum: paymentMethod.min.moneyValue,
            maximum: paymentMethod.max.moneyValue,
            maximumDaily: paymentMethod.maxDaily.moneyValue,
            maximumAnnual: paymentMethod.maxAnnual.moneyValue,
            suggestedUpgrade: nil
        )
        return Just(paymentMethodLimits)
            .setFailureType(to: TransactionLimitsServiceError.self)
            .convertAmounts(
                from: paymentMethod.fiatCurrency.currencyType,
                to: inputCurrency,
                using: conversionService
            )
    }

    private func fetchCrossBorderLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> TransactionLimitsServicePublisher {
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
                limitsCurrency: paymentMethod.fiatCurrency.currencyType
            )
            .map { crossBorderLimits -> TransactionLimits in
                TransactionLimits(crossBorderLimits: crossBorderLimits, paymentMethod: paymentMethod)
            }
            .mapError(TransactionLimitsServiceError.network)
            .convertAmounts(
                from: paymentMethod.fiatCurrency.currencyType,
                to: limitsCurrency,
                using: conversionService
            )
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TransactionLimits, Failure == TransactionLimitsServiceError {

    func convertAmounts(
        from fromCurrency: CurrencyType,
        to toCurrency: CurrencyType,
        using conversionService: CurrencyConversionServiceAPI
    ) -> TransactionLimitsServicePublisher {
        flatMap { originalLimits -> TransactionLimitsServicePublisher in
            conversionService
                .conversionRate(from: fromCurrency, to: toCurrency)
                .map { conversionRate in
                    TransactionLimits(
                        minimum: originalLimits.minimum.convert(using: conversionRate),
                        maximum: originalLimits.maximum.convert(using: conversionRate),
                        maximumDaily: originalLimits.maximumDaily.convert(using: conversionRate),
                        maximumAnnual: originalLimits.maximumAnnual.convert(using: conversionRate),
                        suggestedUpgrade: originalLimits.suggestedUpgrade
                    )
                }
                .mapError(TransactionLimitsServiceError.other)
                .eraseToAnyPublisher()
        }
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
