// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import NetworkError

final class NabuRepository: NabuRepositoryAPI {

    // MARK: - Properties

    private let userCreationClient: NabuUserCreationClientAPI
    private let sessionTokenClient: NabuSessionTokenClientAPI

    // MARK: - Setup

    init(
        userCreationClient: NabuUserCreationClientAPI = resolve(),
        sessionTokenClient: NabuSessionTokenClientAPI = resolve()
    ) {
        self.userCreationClient = userCreationClient
        self.sessionTokenClient = sessionTokenClient
    }

    // MARK: - API

    func createUser(for jwtToken: String) -> AnyPublisher<NabuOfflineToken, NetworkError> {
        userCreationClient
            .createUser(for: jwtToken)
            .map(NabuOfflineToken.init)
            .eraseToAnyPublisher()
    }

    func sessionToken(
        for guid: String,
        userToken: String,
        userIdentifier: String,
        deviceId: String,
        email: String
    ) -> AnyPublisher<NabuSessionToken, NetworkError> {
        sessionTokenClient
            .sessionToken(
                for: guid,
                userToken: userToken,
                userIdentifier: userIdentifier,
                deviceId: deviceId,
                email: email
            )
            .map(NabuSessionToken.init)
            .eraseToAnyPublisher()
    }
}
