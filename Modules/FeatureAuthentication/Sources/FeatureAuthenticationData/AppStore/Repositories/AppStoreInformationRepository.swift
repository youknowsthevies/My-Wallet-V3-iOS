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
    ) -> AnyPublisher<AppStoreApplicationInfo, AppStoreServiceError> {
        client
            .fetchAppStoreResponseForBundleId(bundleId)
            .eraseError()
            .map(\.results)
            .tryMap { applications in
                guard let result = applications.first else {
                    throw AppStoreServiceError.failedToRetrieveAppStoreInfo
                }
                return AppStoreApplicationInfo(
                    version: result.version,
                    isApplicationUpToDate: version == result.version
                )
            }
            .mapError(AppStoreServiceError.networkError)
            .eraseToAnyPublisher()
    }
}
