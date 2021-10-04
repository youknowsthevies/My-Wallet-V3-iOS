// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol MobileAuthSyncRepositoryAPI {
    /// Sends a record to the backend server that the mobile wallet has been setup or not. It is considered successfully setup if the user logs in, and not set when the user forgets the wallet. This is for reporting backend metrics on Grafana.
    /// - Parameters:
    ///   - guid: the wallet GUID
    ///   - sharedKey: the wallet shared key
    ///   - isMobileSetup: true (login) or false (logout)
    /// - Returns: A `Combine.Publisher` that returns Void if successful and `MobileAuthSyncRepositoryError` if failed.
    func updateMobileSetup(
        guid: String,
        sharedKey: String,
        isMobileSetup: Bool
    ) -> AnyPublisher<Void, MobileAuthSyncServiceError>

    /// Sends a record to the backend server that the cloud backup has been created or cleared. The backup is created when the user logs in, and cleared when the user forgets the wallet. This is for reporting backend metrics on Grafana.
    /// - Parameters:
    ///   - guid: the wallet GUID
    ///   - sharedKey: the wallet shared key
    ///   - hasCloudBackup: true (login) or false (logout)
    /// - Returns: A `Combine.Publisher` that returns Void if successful and `MobileAuthSyncRepositoryError` if failed.
    func verifyCloudBackup(
        guid: String,
        sharedKey: String,
        hasCloudBackup: Bool
    ) -> AnyPublisher<Void, MobileAuthSyncServiceError>
}
