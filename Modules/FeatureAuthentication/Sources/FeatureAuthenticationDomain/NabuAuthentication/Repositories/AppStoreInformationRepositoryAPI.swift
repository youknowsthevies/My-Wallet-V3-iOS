// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public enum AppStoreServiceError: Error {
    case failedToRetrieveAppStoreInfo
    case networkError(Error)
}

public protocol AppStoreInformationRepositoryAPI {
    /// Checks that the current app version is the same as the version that is in the AppStore.
    /// - Parameters:
    ///   - version: The wallet GUID
    ///   - bundleId: The wallet sharedKey
    /// - Returns: A `Bool`
    func verifyTheCurrentAppVersionIsTheLatestVersion(
        _ version: String,
        bundleId: String
    ) -> AnyPublisher<Bool, AppStoreServiceError>
}
