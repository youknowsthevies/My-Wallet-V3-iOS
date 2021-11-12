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
        source: LimitsAccount,
        destination: LimitsAccount,
        product: TransactionLimitsProduct
    ) -> TransactionLimitsServicePublisher

    func fetchLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> TransactionLimitsServicePublisher
}

final class TransactionLimitsService: TransactionLimitsServiceAPI {

    private let repository: TransactionLimitsRepositoryAPI
    private let conversionService: CurrencyConversionServiceAPI
    private let walletCurrencyService: FiatCurrencyServiceAPI
    private let featureFlagService: FeatureFlagsServiceAPI

    init(
        repository: TransactionLimitsRepositoryAPI,
        conversionService: CurrencyConversionServiceAPI,
        walletCurrencyService: FiatCurrencyServiceAPI,
        featureFlagService: FeatureFlagsServiceAPI
    ) {
        self.repository = repository
        self.conversionService = conversionService
        self.walletCurrencyService = walletCurrencyService
        self.featureFlagService = featureFlagService
    }

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        product: TransactionLimitsProduct
    ) -> TransactionLimitsServicePublisher {
        Publishers
            .Zip(
                walletCurrencyService.fiatCurrencyPublisher,
                featureFlagService.isEnabled(.local(.newTxFlowLimitsUIEnabled))
            )
            .flatMap { [unowned self] walletCurrency, newLimitsEnabled -> TransactionLimitsServicePublisher in
                let convertedTradeLimits = self
                    .fetchTradeLimits(
                        fiatCurrency: walletCurrency,
                        destination: destination,
                        product: product
                    )
                    .map(TransactionLimits.init)
                    .convertAmounts(
                        from: walletCurrency.currencyType,
                        to: source.currency,
                        using: self.conversionService
                    )
                    .eraseToAnyPublisher()

                guard newLimitsEnabled else {
                    return convertedTradeLimits
                }

                let convertedCrossBorderLimits = self
                    .fetchCrossBorderLimits(
                        source: source,
                        destination: destination,
                        limitsCurrency: walletCurrency
                    )
                return Publishers.Zip(convertedTradeLimits, convertedCrossBorderLimits)
                    .map { $0.merge(with: $1) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func fetchLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> TransactionLimitsServicePublisher {
        featureFlagService.isEnabled(.local(.newTxFlowLimitsUIEnabled))
            .flatMap { [unowned self] newLimitsEnabled -> TransactionLimitsServicePublisher in
                guard newLimitsEnabled else {
                    return .just(TransactionLimits(paymentMethod))
                        .convertAmounts(
                            from: paymentMethod.fiatCurrency.currencyType,
                            to: limitsCurrency,
                            using: conversionService
                        )
                }
                return self.fetchCrossBorderLimits(
                    for: paymentMethod,
                    targetCurrency: targetCurrency,
                    limitsCurrency: limitsCurrency
                )
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Helpers

extension TransactionLimitsService {

    private func fetchTradeLimits(
        fiatCurrency: FiatCurrency,
        destination: LimitsAccount,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TradeLimits, TransactionLimitsServiceError> {
        repository
            .fetchTradeLimits(
                sourceCurrency: fiatCurrency.currencyType,
                destinationCurrency: destination.currency,
                product: product
            )
            .mapError(TransactionLimitsServiceError.network)
            .eraseToAnyPublisher()
    }

    private func fetchCrossBorderLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: FiatCurrency
    ) -> AnyPublisher<CrossBorderLimits, TransactionLimitsServiceError> {
        repository
            .fetchCrossBorderLimits(
                source: source,
                destination: destination,
                limitsCurrency: limitsCurrency
            )
            .mapError(TransactionLimitsServiceError.network)
            .eraseToAnyPublisher()
    }

    private func fetchCrossBorderLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> TransactionLimitsServicePublisher {
        fetchCrossBorderLimits(
            source: LimitsAccount(
                currency: paymentMethod.fiatCurrency.currencyType,
                accountType: paymentMethod.type.isFunds ? .custodial : .nonCustodial
            ),
            destination: LimitsAccount(
                currency: targetCurrency,
                accountType: .custodial
            ),
            limitsCurrency: paymentMethod.fiatCurrency
        )
        .map { crossBorderLimits -> TransactionLimits in
            TransactionLimits(paymentMethod)
                .merge(with: crossBorderLimits)
        }
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

    init(_ tradeLimits: TradeLimits) {
        self.init(
            minimum: tradeLimits.minOrder,
            maximum: tradeLimits.maxPossibleOrder,
            maximumDaily: tradeLimits.daily?.limit ?? tradeLimits.maxPossibleOrder,
            maximumAnnual: tradeLimits.annual?.limit ?? tradeLimits.maxPossibleOrder,
            suggestedUpgrade: nil
        )
    }

    init(_ paymentMethod: PaymentMethod) {
        self.init(
            minimum: paymentMethod.min.moneyValue,
            maximum: paymentMethod.max.moneyValue,
            maximumDaily: paymentMethod.maxDaily.moneyValue,
            maximumAnnual: paymentMethod.maxAnnual.moneyValue,
            suggestedUpgrade: nil
        )
    }

    func merge(with crossBorderLimits: CrossBorderLimits) -> TransactionLimits {
        let infinity = MoneyValue(amount: BigInt(Int.max), currency: crossBorderLimits.currency)
        let maxCrossBorderCurrentLimit = crossBorderLimits.currentLimits?.available ?? infinity
        let maxCrossBorderDailyLimit = crossBorderLimits.currentLimits?.daily?.limit ?? infinity
        let maxCrossBorderAnnualLimit = crossBorderLimits.currentLimits?.yearly?.limit ?? infinity
        let maxCombinedLimit = try? MoneyValue.min(maximum, maxCrossBorderCurrentLimit)
        return TransactionLimits(
            minimum: minimum,
            maximum: maxCombinedLimit ?? maximum,
            maximumDaily: maxCrossBorderDailyLimit,
            maximumAnnual: maxCrossBorderAnnualLimit,
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade
        )
    }
}
