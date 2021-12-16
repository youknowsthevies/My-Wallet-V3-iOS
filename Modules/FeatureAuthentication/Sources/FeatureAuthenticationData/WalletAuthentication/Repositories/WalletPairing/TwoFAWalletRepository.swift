// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import WalletPayloadKit

final class TwoFAWalletRepository: TwoFAWalletRepositoryAPI {

    // MARK: - Properties

    private let apiClient: TwoFAWalletClientAPI

    // MARK: - Setup

    init(apiClient: TwoFAWalletClientAPI = resolve()) {
        self.apiClient = apiClient
    }

    // MARK: - API

    func send(
        guid: String,
        sessionToken: String,
        code: String
    ) -> AnyPublisher<WalletPayloadWrapper, TwoFAWalletServiceError> {
        apiClient
            .payload(guid: guid, sessionToken: sessionToken, code: code)
            .mapError(TwoFAWalletServiceError.from)
            .eraseToAnyPublisher()
    }
}
