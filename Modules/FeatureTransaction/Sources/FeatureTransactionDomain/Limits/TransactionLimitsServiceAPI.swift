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
        destination: LimitsAccount
    ) -> TransactionLimitsServicePublisher

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: FiatCurrency
    ) -> TransactionLimitsServicePublisher

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
        destination: LimitsAccount
    ) -> TransactionLimitsServicePublisher {
        walletCurrencyService.fiatCurrencyPublisher
            .setFailureType(to: TransactionLimitsServiceError.self)
            .flatMap { [unowned self] walletCurrency -> TransactionLimitsServicePublisher in
                self.fetchLimits(source: source, destination: destination, limitsCurrency: walletCurrency)
                    .convertAmounts(
                        from: walletCurrency.currencyType,
                        to: source.currency,
                        using: self.conversionService
                    )
            }
            .eraseToAnyPublisher()
    }

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: FiatCurrency
    ) -> TransactionLimitsServicePublisher {
        featureFlagService.isEnabled(.remote(.newLimitsUIEnabled))
            .flatMap { [unowned self] newLimitsEnabled -> TransactionLimitsServicePublisher in
                guard newLimitsEnabled else {
                    return .just(.noLimits(for: limitsCurrency.currencyType))
                }
                return self.fetchCrossBorderLimits(
                    source: source,
                    destination: destination,
                    limitsCurrency: limitsCurrency
                )
                .map(TransactionLimits.init)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        product: TransactionLimitsProduct
    ) -> TransactionLimitsServicePublisher {
        walletCurrencyService.fiatCurrencyPublisher
            .zip(featureFlagService.isEnabled(.remote(.newLimitsUIEnabled)))
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
                    .convertAmounts(
                        from: walletCurrency.currencyType,
                        to: source.currency,
                        using: self.conversionService
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
        featureFlagService.isEnabled(.remote(.newLimitsUIEnabled))
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
            TransactionLimits.merge(
                paymentMethod: paymentMethod,
                with: crossBorderLimits,
                usePaymentMethodMax: targetCurrency.isFiatCurrency // is true means this is for deposits
            )
        }
        .convertAmounts(
            from: paymentMethod.fiatCurrency.currencyType,
            to: limitsCurrency,
            using: conversionService
        )
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == CrossBorderLimits, Failure == TransactionLimitsServiceError {

    func convertAmounts(
        from fromCurrency: CurrencyType,
        to toCurrency: CurrencyType,
        using conversionService: CurrencyConversionServiceAPI
    ) -> AnyPublisher<CrossBorderLimits, TransactionLimitsServiceError> {
        zip(
            conversionService
                .conversionRate(from: fromCurrency, to: toCurrency)
                .mapError(TransactionLimitsServiceError.other)
        )
        .map { originalLimits, conversionRate in
            originalLimits.convert(using: conversionRate)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TransactionLimits, Failure == TransactionLimitsServiceError {

    func convertAmounts(
        from fromCurrency: CurrencyType,
        to toCurrency: CurrencyType,
        using conversionService: CurrencyConversionServiceAPI
    ) -> TransactionLimitsServicePublisher {
        zip(
            conversionService
                .conversionRate(from: fromCurrency, to: toCurrency)
                .mapError(TransactionLimitsServiceError.other)
        )
        .map { originalLimits, exchangeRate -> TransactionLimits in
            originalLimits.convert(using: exchangeRate)
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
            effectiveLimit: .init(timeframe: .single, value: tradeLimits.maxPossibleOrder),
            suggestedUpgrade: nil
        )
    }

    init(_ paymentMethod: PaymentMethod) {
        self.init(
            minimum: paymentMethod.min.moneyValue,
            maximum: paymentMethod.max.moneyValue,
            maximumDaily: paymentMethod.maxDaily.moneyValue,
            maximumAnnual: paymentMethod.maxAnnual.moneyValue,
            effectiveLimit: .init(timeframe: .single, value: paymentMethod.max.moneyValue),
            suggestedUpgrade: nil
        )
    }

    init(_ crossBorderLimits: CrossBorderLimits) {
        let infinity = MoneyValue.decimalMaximum(for: crossBorderLimits.currency)
        self.init(
            minimum: .zero(currency: crossBorderLimits.currency),
            maximum: crossBorderLimits.currentLimits?.available ?? infinity,
            maximumDaily: crossBorderLimits.currentLimits?.daily?.limit ?? infinity,
            maximumAnnual: crossBorderLimits.currentLimits?.yearly?.limit ?? infinity,
            effectiveLimit: .init(crossBorderLimits: crossBorderLimits, maxLimitFallbak: infinity),
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade
        )
    }

    func merge(with crossBorderLimits: CrossBorderLimits) -> TransactionLimits {
        let infinity = MoneyValue.decimalMaximum(for: crossBorderLimits.currency)
        let maxCrossBorderCurrentLimit = crossBorderLimits.currentLimits?.available ?? infinity
        let maxCombinedLimit = (try? MoneyValue.min(maximum, maxCrossBorderCurrentLimit)) ?? maximum
        let maxCrossBorderDailyLimit = crossBorderLimits.currentLimits?.daily?.limit ?? maxCombinedLimit
        let maxCrossBorderAnnualLimit = crossBorderLimits.currentLimits?.yearly?.limit ?? maxCombinedLimit
        return TransactionLimits(
            minimum: minimum,
            maximum: maxCombinedLimit,
            maximumDaily: maxCrossBorderDailyLimit,
            maximumAnnual: maxCrossBorderAnnualLimit,
            effectiveLimit: .init(crossBorderLimits: crossBorderLimits, maxLimitFallbak: maxCombinedLimit),
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade
        )
    }

    static func merge(
        paymentMethod: PaymentMethod,
        with crossBorderLimits: CrossBorderLimits,
        usePaymentMethodMax: Bool
    ) -> TransactionLimits {
        let infinity = MoneyValue.decimalMaximum(for: crossBorderLimits.currency)
        let maxCrossBorderCurrentLimit = crossBorderLimits.currentLimits?.available ?? infinity
        let maxLimit: MoneyValue
        if usePaymentMethodMax, let max = try? MoneyValue.min(paymentMethod.max.moneyValue, maxCrossBorderCurrentLimit) {
            maxLimit = max
        } else {
            maxLimit = maxCrossBorderCurrentLimit
        }
        let maxCrossBorderDailyLimit = crossBorderLimits.currentLimits?.daily?.limit ?? maxLimit
        let maxCrossBorderAnnualLimit = crossBorderLimits.currentLimits?.yearly?.limit ?? maxCrossBorderDailyLimit
        return TransactionLimits(
            minimum: paymentMethod.min.moneyValue,
            maximum: maxLimit,
            maximumDaily: maxCrossBorderDailyLimit,
            maximumAnnual: maxCrossBorderAnnualLimit,
            effectiveLimit: .init(crossBorderLimits: crossBorderLimits, maxLimitFallbak: maxLimit),
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade
        )
    }
}

extension EffectiveLimit {

    init(crossBorderLimits: CrossBorderLimits, maxLimitFallbak: MoneyValue) {
        let periodicLimits: [(limit: PeriodicLimit?, timeFrame: EffectiveLimit.TimeFrame)] = [
            (crossBorderLimits.currentLimits?.daily, .daily),
            (crossBorderLimits.currentLimits?.monthly, .monthly),
            (crossBorderLimits.currentLimits?.yearly, .yearly)
        ]
        let effectiveLimit = periodicLimits.first(where: { $0.limit?.effective == true })
        self.init(
            timeframe: effectiveLimit?.timeFrame ?? .single,
            value: effectiveLimit?.limit?.limit ?? maxLimitFallbak
        )
    }
}
