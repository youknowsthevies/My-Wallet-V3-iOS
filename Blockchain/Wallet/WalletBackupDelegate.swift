// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@objc protocol WalletBackupDelegate: class {

    /// Method invoked when backup sequence is completed
    func didBackupWallet()

    /// Method invoked when backup attempt fails
    func didFailBackupWallet()
}
