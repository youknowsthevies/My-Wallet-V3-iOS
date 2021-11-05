// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import NetworkError

class MockNabuRepository: NabuRepositoryAPI {

    var expectedOfflineToken: Result<NabuOfflineToken, NetworkError>!
    var expectedSessionToken: Result<NabuSessionToken, NetworkError>!

    func createUser(for jwtToken: String) -> AnyPublisher<NabuOfflineToken, NetworkError> {
        expectedOfflineToken.publisher.eraseToAnyPublisher()
    }

    func sessionToken(
        for guid: String,
        userToken: String,
        userIdentifier: String,
        deviceId: String,
        email: String
    ) -> AnyPublisher<NabuSessionToken, NetworkError> {
        expectedSessionToken.publisher.eraseToAnyPublisher()
    }
}
