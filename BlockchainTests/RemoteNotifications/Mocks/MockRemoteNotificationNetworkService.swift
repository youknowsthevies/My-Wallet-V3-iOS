// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

@testable import Blockchain

final class MockRemoteNotificationNetworkService: RemoteNotificationNetworkServicing {
    let expectedResult: Result<Void, RemoteNotificationNetworkService.PushNotificationError>
    
    init(expectedResult: Result<Void, RemoteNotificationNetworkService.PushNotificationError>) {
        self.expectedResult = expectedResult
    }
    
    func register(with token: String,
                  using credentialsProvider: SharedKeyRepositoryAPI & GuidRepositoryAPI) -> Single<Void> {
        expectedResult.single
    }
}
