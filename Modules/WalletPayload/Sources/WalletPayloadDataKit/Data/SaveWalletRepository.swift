// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkError
import WalletPayloadKit

final class SaveWalletRepository: SaveWalletRepositoryAPI {

    private let client: SaveWalletClientAPI

    init(client: SaveWalletClientAPI) {
        self.client = client
    }

    func saveWallet(
        payload: WalletCreationPayload,
        addresses: String?
    ) -> AnyPublisher<Void, NetworkError> {
        client.saveWallet(payload: payload, addresses: addresses)
            .eraseToAnyPublisher()
    }
}
