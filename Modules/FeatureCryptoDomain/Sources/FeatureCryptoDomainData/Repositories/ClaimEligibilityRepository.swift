// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCryptoDomainDomain

public final class ClaimEligibilityRepository: ClaimEligibilityRepositoryAPI {

    // MARK: - Properties

    private let apiClient: ClaimEligibilityClientAPI

    // MARK: - Setup

    public init(
        apiClient: ClaimEligibilityClientAPI
    ) {
        self.apiClient = apiClient
    }

    // MARK: - API

    public func checkClaimEligibility() -> AnyPublisher<Bool, Never> {
        apiClient
            .getEligibility()
            .map(\.isEligible)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
