// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit
import WalletCore

typealias ProvideWallet = () -> Wallet
typealias WalletCreating = (BlockchainWallet) -> ProvideWallet

/// Responsible for holding a decoded wallet in memory
final class WalletHolder: WalletHolderAPI, InMemoryWalletProviderAPI, ReleasableWalletAPI {
    private(set) var wallet = Atomic<Wallet?>(nil)

    func provideWallet() -> Wallet? {
        wallet.value
    }

    func hold(
        using creator: @escaping ProvideWallet
    ) -> AnyPublisher<Wallet, Never> {
        Deferred { [creator] in
            Future<Wallet, Never> { promise in
                promise(
                    .success(
                        creator()
                    )
                )
            }
        }
        .handleEvents(
            receiveOutput: { [weak wallet] value in
                wallet?.mutate { $0 = value }
            }
        )
        .setFailureType(to: Never.self)
        .eraseToAnyPublisher()
    }

    public func release() {
        // TODO: It might be more than just this... revisit
        wallet.mutate { $0 = nil }
    }
}

/// Creates a new `Wallet` object
/// - Parameter blockchainWallet: A value of `BlockchainWallet`
/// - Returns: A function that provides a new `Wallet` object
func createWallet(
    from blockchainWallet: BlockchainWallet
) -> () -> Wallet {
    { Wallet(from: blockchainWallet) }
}
