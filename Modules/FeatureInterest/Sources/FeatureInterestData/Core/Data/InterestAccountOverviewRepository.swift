// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureInterestDomain
import PlatformKit
import ToolKit

public final class InterestAccountOverviewRepository: InterestAccountOverviewRepositoryAPI {

    // MARK: - Private Properties

    private let interestAccountEligibilityRepository: InterestAccountEligibilityRepositoryAPI
    private let interestAccountRateRepository: InterestAccountRateRepositoryAPI
    private let interestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI

    // MARK: - Init

    init(
        interestAccountEligibilityRepository: InterestAccountEligibilityRepositoryAPI = resolve(),
        interestAccountRateRepository: InterestAccountRateRepositoryAPI = resolve(),
        interestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI = resolve()
    ) {
        self.interestAccountRateRepository = interestAccountRateRepository
        self.interestAccountEligibilityRepository = interestAccountEligibilityRepository
        self.interestAccountBalanceRepository = interestAccountBalanceRepository
    }

    // MARK: - InterestAccountOverviewRepositoryAPI

    public func fetchInterestAccountOverviewListForFiatCurrency(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[InterestAccountOverview], InterestAccountOverviewError> {
        Publishers.Zip3(
            interestAccountEligibilityRepository
                .fetchAllInterestAccountEligibility()
                .mapError(InterestAccountOverviewError.networkError),
            interestAccountRateRepository
                .fetchAllInterestAccountRates()
                .mapError(InterestAccountOverviewError.networkError),
            interestAccountBalanceRepository
                .fetchInterestAccountsBalance(fiatCurrency: fiatCurrency)
                .mapError(InterestAccountOverviewError.networkError)
        )
        .map { accountEligibilities, accountRates, accountBalances -> [InterestAccountOverview] in
            accountEligibilities
                .compactMap { accountEligibility -> InterestAccountOverview? in
                    let currencyType = accountEligibility.currencyType
                    let code = accountEligibility.currencyType.code
                    let rates = accountRates
                        .filter { .crypto($0.cryptoCurrency) == currencyType }
                    let balance = accountBalances.balances[code]

                    guard let interestAccountRate = rates.first else {
                        Logger.shared.debug(
                            "Interest rate unavailable for currency code: \(accountEligibility.currencyType.code)"
                        )
                        return nil
                    }
                    return InterestAccountOverview(
                        interestAccountEligibility: accountEligibility,
                        interestAccountRate: interestAccountRate,
                        balanceDetails: balance
                    )
                }
        }
        .eraseToAnyPublisher()
    }
}
