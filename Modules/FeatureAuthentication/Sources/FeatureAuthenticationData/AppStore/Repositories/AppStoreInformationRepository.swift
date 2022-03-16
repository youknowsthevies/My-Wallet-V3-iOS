// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain

final class AppStoreInformationRepository: AppStoreInformationRepositoryAPI {

    // MARK: - Properties

    private let client: AppStoreInformationClientAPI

    // MARK: - Setup

    init(client: AppStoreInformationClientAPI = resolve()) {
        self.client = client
    }

    func verifyTheCurrentAppVersionIsTheLatestVersion(
        _ version: String,
        bundleId: String
    ) -> AnyPublisher<Bool, AppStoreServiceError> {
        client
            .fetchAppStoreResponseForBundleId(bundleId)
            .eraseError()
            .map(\.applications)
            .tryMap { applications in
                guard let result = applications.first else {
                    throw AppStoreServiceError.failedToRetrieveAppStoreInfo
                }
                return result.version
            }
            .map { version == $0 }
            .mapError(AppStoreServiceError.networkError)
            .eraseToAnyPublisher()
    }
}
