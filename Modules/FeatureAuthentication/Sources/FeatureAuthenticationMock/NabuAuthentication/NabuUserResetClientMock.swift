// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain

final class NabuResetUserClientMock: NabuResetUserClientAPI {

    var expectedResult: Result<Void, NetworkError>!

    func resetUser(
        offlineToken: NabuOfflineTokenResponse,
        jwt: String
    ) -> AnyPublisher<Void, NetworkError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}
