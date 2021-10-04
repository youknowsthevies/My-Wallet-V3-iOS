// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import NetworkKit

protocol NabuUserRecoveryClientAPI: AnyObject {

    func recoverUser(
        offlineToken: NabuOfflineTokenResponse,
        jwt: String,
        userId: String,
        recoveryToken: String
    ) -> AnyPublisher<NabuOfflineTokenResponse, NetworkError>
}

final class NabuUserRecoveryClient: NabuUserRecoveryClientAPI {

    // MARK: - Type

    private enum Path {
        static func recovery(userId: String) -> [String] {
            ["users", "recovery", userId]
        }
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func recoverUser(
        offlineToken: NabuOfflineTokenResponse,
        jwt: String,
        userId: String,
        recoveryToken: String
    ) -> AnyPublisher<NabuOfflineTokenResponse, NetworkError> {
        let request = requestBuilder.post(
            path: Path.recovery(userId: userId),
            body: try? NabuUserRecoveryPayload(jwt: jwt, recoveryToken: recoveryToken).encode()
        )!
        return networkAdapter.perform(request: request)
    }
}
