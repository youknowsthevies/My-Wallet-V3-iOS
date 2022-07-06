// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import PlatformKit

public protocol ReferralServiceAPI {
    func fetchReferralCampaign() -> AnyPublisher<Referral?, Never>
    func createReferral(with code: String) -> AnyPublisher<Void, NetworkError>
}

public class ReferralService: ReferralServiceAPI {
    private let repository: ReferralRepositoryAPI
    private let currencyService: FiatCurrencyServiceAPI

    public init(
        repository: ReferralRepositoryAPI,
        currencyService: FiatCurrencyServiceAPI
    ) {
        self.repository = repository
        self.currencyService = currencyService
    }

    public func createReferral(with code: String) -> AnyPublisher<Void, NetworkError> {
        repository
            .createReferral(with: code)
            .eraseToAnyPublisher()
    }

    public func fetchReferralCampaign() -> AnyPublisher<Referral?, Never> {
        currencyService
            .currency
            .flatMap { [repository] currency in
                repository
                    .fetchReferralCampaign(for: currency.code)
            }
            .optional()
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
