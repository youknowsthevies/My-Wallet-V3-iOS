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
            .mapError(AppStoreServiceError.networkError)
            .map(\.results)
            .flatMap { applications -> AnyPublisher<AppStoreApplicationInfo, AppStoreServiceError> in
                guard let result = applications.first else {
                    return .failure(.failedToRetrieveAppStoreInfo)
                }
                return .just(
                    AppStoreApplicationInfo(
                        version: result.version,
                        isApplicationUpToDate: version == result.version
                    )
                )
            }
            .eraseToAnyPublisher()
    }
}
