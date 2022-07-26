// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public typealias MnemonicVerificationStatusProvider = () -> AnyPublisher<Bool, Never>

/// Returns a closure that provides a `AnyPublisher<Bool, Never>`
/// that determines the status of the mnemonic verification
/// - Parameter walletHolder: A `WalletHolderAPI`
/// - Returns: `() -> AnyPublisher<Bool, Never>`
func provideMnemonicVerificationStatus(
    walletHolder: WalletHolderAPI
) -> () -> AnyPublisher<Bool, Never> {
    { [walletHolder] in
        walletHolder.walletStatePublisher
            .map { walletState -> Bool in
                guard let wallet = walletState?.wrapper?.wallet else {
                    return false
                }
                return wallet.isMnemonicVerified
            }
            .eraseToAnyPublisher()
    }
}
