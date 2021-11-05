// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

final class WalletLogic {

    private let holder: WalletHolderAPI
    private let creator: WalletCreating

    init(
        holder: WalletHolderAPI,
        creator: @escaping WalletCreating = createWallet(from:)
    ) {
        self.holder = holder
        self.creator = creator
    }

    /// Initialises a `Wallet` using the given payload data
    /// - Parameter payload: A `Data` value representing a valid decrypted wallet payload
    /// - Returns: `AnyPublisher<EmptyValue, WalletError>`
    func initialize(
        using payload: Data
    ) -> AnyPublisher<Wallet, WalletError> {
        decode(data: payload)
            .flatMap { [holder, creator] blockchainWallet -> AnyPublisher<Wallet, Never> in
                holder.hold(
                    using: creator(blockchainWallet)
                )
            }
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
