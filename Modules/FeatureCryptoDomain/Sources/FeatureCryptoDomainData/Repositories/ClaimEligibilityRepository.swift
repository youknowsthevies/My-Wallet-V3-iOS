// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import FeatureCryptoDomainDomain

public final class ClaimEligibilityRepository: ClaimEligibilityRepositoryAPI {

    // MARK: - Properties

    private let offlineTokenRepository: NabuOfflineTokenRepositoryAPI
    private let apiClient: ClaimEligibilityClientAPI

    // MARK: - Setup

    public init(
        offlineTokenRepository: NabuOfflineTokenRepositoryAPI,
        apiClient: ClaimEligibilityClientAPI
    ) {
        self.offlineTokenRepository = offlineTokenRepository
        self.apiClient = apiClient
    }

    // MARK: - API

    public func checkClaimEligibility() -> AnyPublisher<Bool, Never> {
        offlineTokenRepository
            .offlineToken
            .eraseError()
            .flatMap { [apiClient] offlineToken in
                apiClient
                    .getEligibility(offlineToken: offlineToken)
                    .eraseError()
                    .eraseToAnyPublisher()
            }
            .map(\.isEligible)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
