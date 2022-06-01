// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain

final class NabuSessionTokenClientMock: NabuSessionTokenClientAPI {

    var expectedResult: Result<NabuSessionTokenResponse, NetworkError>!

    func sessionToken(
        for guid: String,
        userToken: String,
        userIdentifier: String,
        deviceId: String,
        email: String
    ) -> AnyPublisher<NabuSessionTokenResponse, NetworkError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}
