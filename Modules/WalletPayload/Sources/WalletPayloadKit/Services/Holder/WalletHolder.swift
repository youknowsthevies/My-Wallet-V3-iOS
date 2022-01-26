// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit
import WalletCore

typealias WalletCreating = (BlockchainWallet) -> Wallet

/// Responsible for holding a decoded wallet in memory
final class WalletHolder: WalletHolderAPI, ReleasableWalletAPI {

    var walletStatePublisher: AnyPublisher<WalletState?, Never> {
        walletState.publisher
    }

    private(set) var walletState = Atomic<WalletState?>(nil)

    func provideWalletState() -> WalletState? {
        walletState.value
    }

    func hold(
        walletState: WalletState
    ) -> AnyPublisher<WalletState, Never> {
        Deferred { [weak self] in
            Future<WalletState, Never> { promise in
                self?.walletState.mutate { $0 = walletState }
                promise(
                    .success(walletState)
                )
            }
        }
        .setFailureType(to: Never.self)
        .eraseToAnyPublisher()
    }

    func release() {
        // TODO: It might be more than just this... revisit
        walletState.mutate { $0 = nil }
    }
}

/// Creates a new `Wallet` object
/// - Parameter blockchainWallet: A value of `BlockchainWallet`
/// - Returns: A function that provides a new `Wallet` object
func createWallet(
    from blockchainWallet: BlockchainWallet
) -> Wallet {
    Wallet(from: blockchainWallet)
}
