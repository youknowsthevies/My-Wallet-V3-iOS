// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import NetworkError

final class SaveWalletRepositoryMock: SaveWalletRepositoryAPI {
    var saveWalletCalled: Bool = false
    var payload: WalletCreationPayload?
    var saveWalletResult: Result<Void, NetworkError> = .failure(.serverError(.badResponse))
    func saveWallet(
        payload: WalletCreationPayload,
        addresses: String?
    ) -> AnyPublisher<Void, NetworkError> {
        saveWalletCalled = true
        self.payload = payload
        return saveWalletResult
            .publisher
            .eraseToAnyPublisher()
    }
}
