// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import MoneyKit
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
        limitsCurrency: CurrencyType,
        product: TransactionLimitsProduct
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
        walletCurrencyService.displayCurrencyPublisher
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
        walletCurrencyService.displayCurrencyPublisher
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
        limitsCurrency: CurrencyType,
        product: TransactionLimitsProduct
    ) -> TransactionLimitsServicePublisher {
        fetchTradeLimits(
            fiatCurrency: paymentMethod.fiatCurrency,
            destination: LimitsAccount(
                currency: targetCurrency,
                accountType: .custodial
            ),
            product: product
        )
        .flatMap { [conversionService] tradeLimits -> TransactionLimitsServicePublisher in
            let limits = TransactionLimits(tradeLimits).merge(with: TransactionLimits(paymentMethod))
            return .just(limits)
                .convertAmounts(
                    from: tradeLimits.currency,
                    to: limitsCurrency,
                    using: conversionService
                )
        }
        .flatMap { [featureFlagService] transactionLimits in
            featureFlagService
                .isEnabled(.remote(.newLimitsUIEnabled))
                .flatMap { [unowned self] newLimitsEnabled -> TransactionLimitsServicePublisher in
                    guard newLimitsEnabled else {
                        return .just(transactionLimits)
                    }
                    return self.fetchCrossBorderLimits(
                        for: paymentMethod,
                        targetCurrency: targetCurrency,
                        limitsCurrency: limitsCurrency
                    )
                }
                .map { crossBorderLimits -> TransactionLimits in
                    transactionLimits.merge(with: crossBorderLimits)
                }
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
            currencyType: tradeLimits.currency,
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
            currencyType: paymentMethod.fiatCurrency.currencyType,
            minimum: paymentMethod.min.moneyValue,
            maximum: paymentMethod.max.moneyValue,
            maximumDaily: paymentMethod.maxDaily.moneyValue,
            maximumAnnual: paymentMethod.maxAnnual.moneyValue,
            effectiveLimit: .init(timeframe: .single, value: paymentMethod.max.moneyValue),
            suggestedUpgrade: nil
        )
    }

    init(_ crossBorderLimits: CrossBorderLimits) {
        let effectiveLimit: EffectiveLimit?
        if let maxCurrentLimit = crossBorderLimits.currentLimits?.available {
            effectiveLimit = .init(crossBorderLimits: crossBorderLimits, maxLimitFallbak: maxCurrentLimit)
        } else {
            effectiveLimit = nil
        }
        self.init(
            currencyType: crossBorderLimits.currency,
            minimum: .zero(currency: crossBorderLimits.currency),
            maximum: crossBorderLimits.currentLimits?.available,
            maximumDaily: crossBorderLimits.currentLimits?.daily?.limit,
            maximumAnnual: crossBorderLimits.currentLimits?.yearly?.limit,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade
        )
    }

    func merge(with limits: TransactionLimits) -> TransactionLimits {
        guard currencyType == limits.currencyType else {
            fatalError("Merging limits with mismatching currency types is not allowed")
        }

        let effectiveLimit: EffectiveLimit? = try? .max(effectiveLimit, limits.effectiveLimit)
        let suggestedUpgrade: SuggestedLimitsUpgrade?
        if let lhs = effectiveLimit, let rhs = limits.effectiveLimit {
            suggestedUpgrade = try? lhs.value > rhs.value ? self.suggestedUpgrade : limits.suggestedUpgrade
        } else {
            suggestedUpgrade = self.suggestedUpgrade ?? limits.suggestedUpgrade
        }

        let defaultMin = limits.minimum ?? minimum
        let defaultMax = limits.maximum ?? maximum
        let combinedMax = (try? .max(limits.maximum, maximum)) ?? defaultMax
        let defaultMaxDaily = limits.maximumDaily ?? maximumDaily ?? combinedMax
        let defaultMaxAnnual = limits.maximumAnnual ?? maximumAnnual ?? defaultMaxDaily

        return TransactionLimits(
            currencyType: limits.currencyType,
            minimum: (try? .max(limits.minimum, minimum)) ?? defaultMin,
            maximum: combinedMax,
            maximumDaily: (try? .max(limits.maximumDaily, maximumDaily)) ?? defaultMaxDaily,
            maximumAnnual: (try? .max(limits.maximumAnnual, maximumAnnual)) ?? defaultMaxAnnual,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: suggestedUpgrade
        )
    }

    func merge(with crossBorderLimits: CrossBorderLimits) -> TransactionLimits {
        let maxCrossBorderCurrentLimit = crossBorderLimits.currentLimits?.available
        let maxCombinedLimit: MoneyValue?
        if let maximum = maximum, let maxCrossBorderCurrentLimit = maxCrossBorderCurrentLimit {
            maxCombinedLimit = (try? MoneyValue.min(maximum, maxCrossBorderCurrentLimit)) ?? maximum
        } else {
            maxCombinedLimit = maxCrossBorderCurrentLimit ?? maximum
        }
        let maxCrossBorderDailyLimit = crossBorderLimits.currentLimits?.daily?.limit ?? maxCombinedLimit
        let maxCrossBorderAnnualLimit = crossBorderLimits.currentLimits?.yearly?.limit ?? maxCombinedLimit
        let effectiveLimit: EffectiveLimit?
        if let maxCombinedLimit = maxCombinedLimit {
            effectiveLimit = .init(crossBorderLimits: crossBorderLimits, maxLimitFallbak: maxCombinedLimit)
        } else {
            effectiveLimit = nil
        }
        return TransactionLimits(
            currencyType: crossBorderLimits.currency,
            minimum: minimum,
            maximum: maxCombinedLimit,
            maximumDaily: maxCrossBorderDailyLimit,
            maximumAnnual: maxCrossBorderAnnualLimit,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade
        )
    }

    static func merge(
        paymentMethod: PaymentMethod,
        with crossBorderLimits: CrossBorderLimits,
        usePaymentMethodMax: Bool
    ) -> TransactionLimits {
        let maxCrossBorderCurrentLimit = crossBorderLimits.currentLimits?.available ?? paymentMethod.max.moneyValue
        let maxLimit: MoneyValue
        if usePaymentMethodMax, let m = try? MoneyValue.min(paymentMethod.max.moneyValue, maxCrossBorderCurrentLimit) {
            maxLimit = m
        } else {
            maxLimit = maxCrossBorderCurrentLimit
        }
        let maxCrossBorderDailyLimit = crossBorderLimits.currentLimits?.daily?.limit ?? maxLimit
        let maxCrossBorderAnnualLimit = crossBorderLimits.currentLimits?.yearly?.limit ?? maxCrossBorderDailyLimit
        return TransactionLimits(
            currencyType: crossBorderLimits.currency,
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
