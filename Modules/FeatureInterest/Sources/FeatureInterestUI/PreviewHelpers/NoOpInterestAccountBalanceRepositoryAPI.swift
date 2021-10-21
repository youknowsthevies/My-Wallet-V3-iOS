// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureInterestDomain
import PlatformKit

final class NoOpInterestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI {
    func fetchInterestAccountsBalance(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountBalances, InterestAccountBalanceRepositoryError> {
        Deferred {
            Future { _ in
            }
        }
        .eraseToAnyPublisher()
    }
}
