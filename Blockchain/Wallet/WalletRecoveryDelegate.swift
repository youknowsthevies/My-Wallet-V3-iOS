// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@objc protocol WalletRecoveryDelegate: class {

    /// Method invoked when the recovery sequence is completed
    func didRecoverWallet()

    /// Method invoked when the recovery sequence fails to complete
    func didFailRecovery()
}
