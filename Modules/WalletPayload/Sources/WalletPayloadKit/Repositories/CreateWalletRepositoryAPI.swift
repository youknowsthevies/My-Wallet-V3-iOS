// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public protocol CreateWalletRepositoryAPI {

    /// Creates a wallet on the backend
    /// - Returns: `AnyPublisher<Void, WalletCreateError>`
    func createWallet(
        email: String,
        payload: WalletCreationPayload
    ) -> AnyPublisher<Void, NetworkError>
}
