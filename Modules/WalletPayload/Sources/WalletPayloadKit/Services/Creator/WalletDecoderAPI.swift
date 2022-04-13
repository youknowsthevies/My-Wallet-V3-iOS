// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public typealias WalletDecoding = (WalletPayload, Data) -> AnyPublisher<Wrapper, WalletError>

/// Types implementing `WalletDecoderAPI` should be able to create a `Wallet` model.
public protocol WalletDecoderAPI {
    /// Creates a new `Wallet` object
    ///
    /// - Parameter walletPayload: A `WalletPayload` value
    /// - Parameter decryptedData: A value of `Data`
    /// - Returns: A function that provides a new `Wrapper` object
    func createWallet(from walletPayload: WalletPayload, decryptedData: Data) -> AnyPublisher<Wrapper, WalletError>
}
