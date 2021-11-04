// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

final class WalletLogic {

    func initialize(using payload: Data) -> AnyPublisher<EmptyValue, WalletError> {
        decode(data: payload)
            .map { _ in .noValue }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func decode(data: Data) -> AnyPublisher<BlockchainWallet, WalletError> {
        Result {
            try JSONDecoder().decode(BlockchainWallet.self, from: data)
        }
        .mapError { WalletError.decryption(.decodeError($0)) }
        .publisher
        .eraseToAnyPublisher()
    }
}
