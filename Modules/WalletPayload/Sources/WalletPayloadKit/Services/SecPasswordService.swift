// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

public protocol SecondPasswordServiceAPI {
    /// `true` if the wallet is encrypted with second password, otherwise false
    var walletRequiresSecondPassword: Bool { get }

    /// Validates if the given password is valid
    /// - Parameters:
    ///   - secondPassword: A string representing user's second password
    /// - Returns: `true` if the passed password is valid, otherwise false
    func validate(secondPassword: String) -> Bool
}

final class SecondPasswordService: SecondPasswordServiceAPI {

    var walletRequiresSecondPassword: Bool {
        guard let wallet = walletHolder.provideWalletState()?.wallet else {
            return false
        }
        return wallet.doubleEncrypted
    }

    private let walletHolder: WalletHolderAPI

    init(walletHolder: WalletHolderAPI) {
        self.walletHolder = walletHolder
    }

    func validate(secondPassword: String) -> Bool {
        guard let wallet = walletHolder.provideWalletState()?.wallet else {
            return false
        }
        return isValid(
            secondPassword: secondPassword,
            wallet: wallet
        )
    }
}
