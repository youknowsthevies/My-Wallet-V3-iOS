// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain

final class MockMobileAuthSyncService: MobileAuthSyncServiceAPI {

    func updateMobileSetup(isMobileSetup: Bool) -> AnyPublisher<Void, MobileAuthSyncServiceError> {
        .just(())
    }

    func verifyCloudBackup(hasCloudBackup: Bool) -> AnyPublisher<Void, MobileAuthSyncServiceError> {
        .just(())
    }
}
