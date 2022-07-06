// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain

final class NabuUserCreationClientMock: NabuUserCreationClientAPI {

    var expectedResult: Result<NabuOfflineTokenResponse, NetworkError>!

    func createUser(
        for jwtToken: String
    ) -> AnyPublisher<NabuOfflineTokenResponse, NetworkError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}
