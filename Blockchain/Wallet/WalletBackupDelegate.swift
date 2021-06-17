// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@objc protocol WalletBackupDelegate: AnyObject {

    /// Method invoked when backup sequence is completed
    func didBackupWallet()

    /// Method invoked when backup attempt fails
    func didFailBackupWallet()
}
