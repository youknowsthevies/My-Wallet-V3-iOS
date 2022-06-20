// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public protocol SaveWalletRepositoryAPI {

    /// Save a wallet on the backend
    /// - Returns: `AnyPublisher<Void, NetworkError>`
    func saveWallet(
        payload: WalletCreationPayload,
        addresses: String?
    ) -> AnyPublisher<Void, NetworkError>
}
