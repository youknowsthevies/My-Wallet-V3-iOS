// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public typealias WalletCreating = (Data) -> AnyPublisher<NativeWallet, WalletError>

/// Types implementing `WalletCreatorAPI` should be able to create a `Wallet` model.
public protocol WalletCreatorAPI {
    /// Creates a new `Wallet` object
    /// - Parameter data: A value of `Data`
    /// - Returns: A function that provides a new `Wallet` object
    func createWallet(from data: Data) -> AnyPublisher<NativeWallet, WalletError>
}
