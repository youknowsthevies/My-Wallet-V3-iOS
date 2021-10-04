// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import NetworkError

final class MobileAuthSyncRepository: MobileAuthSyncRepositoryAPI {

    // MARK: - Properties

    private let apiClient: MobileAuthSyncClientAPI

    // MARK: - Setup

    init(
        apiClient: MobileAuthSyncClientAPI = resolve()
    ) {
        self.apiClient = apiClient
    }

    // MARK: - API

    func updateMobileSetup(
        guid: String,
        sharedKey: String,
        isMobileSetup: Bool
    ) -> AnyPublisher<Void, MobileAuthSyncServiceError> {
        apiClient
            .updateMobileSetup(guid: guid, sharedKey: sharedKey, isMobileSetup: isMobileSetup)
            .mapError(MobileAuthSyncServiceError.networkError)
            .eraseToAnyPublisher()
    }

    func verifyCloudBackup(
        guid: String,
        sharedKey: String,
        hasCloudBackup: Bool
    ) -> AnyPublisher<Void, MobileAuthSyncServiceError> {
        apiClient
            .verifyCloudBackup(guid: guid, sharedKey: sharedKey, hasCloudBackUp: hasCloudBackup)
            .mapError(MobileAuthSyncServiceError.networkError)
            .eraseToAnyPublisher()
    }
}
