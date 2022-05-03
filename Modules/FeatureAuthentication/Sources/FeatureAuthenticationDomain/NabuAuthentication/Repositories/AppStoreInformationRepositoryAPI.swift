// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public enum AppStoreServiceError: Error {
    case failedToRetrieveAppStoreInfo
    case networkError(NetworkError)
}

public protocol AppStoreInformationRepositoryAPI {
    /// Checks that the current app version is the same as the version that is in the AppStore.
    /// - Parameters:
    ///   - version: the current app version
    ///   - bundleId: the app bundle ID
    /// - Returns: `AppStoreApplicationInfo`
    func verifyTheCurrentAppVersionIsTheLatestVersion(
        _ version: String,
        bundleId: String
    ) -> AnyPublisher<AppStoreApplicationInfo, AppStoreServiceError>
}
