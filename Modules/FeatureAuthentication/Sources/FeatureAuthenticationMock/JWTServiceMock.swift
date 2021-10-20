// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain

final class JWTClientMock: JWTClientAPI {

    var expectedResult: Result<String, JWTClient.ClientError>!

    func requestJWT(guid: String, sharedKey: String) -> AnyPublisher<String, JWTClient.ClientError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}

final class JWTRepositoryMock: JWTRepositoryAPI {

    var expectedResult: Result<String, JWTServiceError>!

    func requestJWT(guid: String, sharedKey: String) -> AnyPublisher<String, JWTServiceError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}

final class JWTServiceMock: JWTServiceAPI {

    var expectedResult: Result<String, JWTServiceError>!

    var token: AnyPublisher<String, JWTServiceError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }

    func fetchToken(guid: String, sharedKey: String) -> AnyPublisher<String, JWTServiceError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}
