// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// Types adopting the `WalletHolderAPI` protocol provide in-memory `Wallet` object.
public protocol WalletHolderAPI {

    var walletStatePublisher: AnyPublisher<WalletState?, Never> { get }

    /// Returns a `Wallet` object if it exists, otherwise `nil`
    func provideWalletState() -> WalletState?

    /// Stores a given `WalletState`
    /// - Parameter walletState: A `WalletState` to be stoed
    /// - Returns: `AnyPublisher<WalletState, Never>`
    func hold(
        walletState: WalletState
    ) -> AnyPublisher<WalletState, Never>

    /// Releases a in-memory `Wallet` object
    func release()
}
