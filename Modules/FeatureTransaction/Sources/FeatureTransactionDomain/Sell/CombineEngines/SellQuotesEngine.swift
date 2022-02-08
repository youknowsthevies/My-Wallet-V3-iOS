// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import NabuNetworkError
import PlatformKit

final class SellQuotesEngine {

    // MARK: - Constants

    private enum Constants {
        static let retryCount = 3
    }

    // MARK: - Private Properties

    private let repository: OrderQuoteRepositoryAPI

    private let stopSubject = PassthroughSubject<Void, Never>()
    private let amount = CurrentValueSubject<BigInt, Never>(.zero)

    // MARK: - Init

    init(repository: OrderQuoteRepositoryAPI = resolve()) {
        self.repository = repository
    }

    // MARK: - Public Functions

    func stop() {
        stopSubject.send(())
    }

    func update(amount: BigInt) {
        self.amount.send(amount)
    }

    func startPollingRate(
        direction: OrderDirection,
        pair: OrderPair
    ) -> AnyPublisher<PricedQuote, Never> {
        Publishers.CombineLatest(
            startPollingQuote(direction: direction, pair: pair).ignoreFailure(),
            amount
        )
        .map { quote, amount -> PricedQuote in
            let interpolator = PricesInterpolator(prices: quote.quote.priceTiers)
            return PricedQuote(
                price: interpolator.rate(amount: amount),
                networkFee: quote.networkFee,
                staticFee: quote.staticFee,
                sampleDepositAddress: quote.sampleDepositAddress
            )
        }
        .eraseToAnyPublisher()
        .shareReplay()
    }

    // MARK: - Private Functions

    private func startPollingQuote(
        direction: OrderDirection,
        pair: OrderPair
    ) -> AnyPublisher<OrderQuotePayload, NabuNetworkError> {
        let quotePublisher = repository
            .fetchQuote(
                direction: direction,
                sourceCurrencyType: pair.sourceCurrencyType,
                destinationCurrencyType: pair.destinationCurrencyType
            )
            .retry(Constants.retryCount)
            .eraseToAnyPublisher()

        return quotePublisher
            .flatMap { [weak self] quote -> AnyPublisher<OrderQuotePayload, NabuNetworkError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let stopSubject = self.stopSubject
                return Timer
                    .publish(
                        every: quote.expiresAt.timeIntervalSince(quote.createdAt),
                        on: .current,
                        in: .default
                    )
                    .autoconnect()
                    .flatMap { _ in quotePublisher }
                    .prepend(quote)
                    .prefix(untilOutputFrom: stopSubject)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
