// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain

final class AutoWalletPairingRepository: AutoWalletPairingRepositoryAPI {

    // MARK: - Properties

    private let apiClient: AutoWalletPairingClientAPI

    // MARK: - Setup

    init(apiClient: AutoWalletPairingClientAPI = resolve()) {
        self.apiClient = apiClient
    }

    // MARK: - API

    func pair(using pairingData: PairingData) -> AnyPublisher<String, AutoWalletPairingServiceError> {
        apiClient
            .request(guid: pairingData.guid)
            .mapError(AutoWalletPairingServiceError.networkError)
            .eraseToAnyPublisher()
    }

    func encryptionPhrase(using guid: String) -> AnyPublisher<String, AutoWalletPairingServiceError> {
        apiClient
            .request(guid: guid)
            .mapError(AutoWalletPairingServiceError.networkError)
            .eraseToAnyPublisher()
    }
}
