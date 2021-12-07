// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain

final class WalletPayloadRepository: WalletPayloadRepositoryAPI {

    // MARK: - Properties

    private let apiClient: WalletPayloadClientAPI

    // MARK: - Setup

    init(apiClient: WalletPayloadClientAPI = resolve()) {
        self.apiClient = apiClient
    }

    // MARK: - API

    func payload(
        guid: String,
        identifier: WalletPayloadIdentifier
    ) -> AnyPublisher<WalletPayload, WalletPayloadServiceError> {
        apiClient
            .payload(guid: guid, identifier: identifier)
            .map(WalletPayload.init)
            .mapError(WalletPayloadServiceError.init)
            .eraseToAnyPublisher()
    }
}
