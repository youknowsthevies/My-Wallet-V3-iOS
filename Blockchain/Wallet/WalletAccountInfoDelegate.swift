// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Protocol definition for a delegate for accountinfo-related wallet callbacks
protocol WalletAccountInfoDelegate: AnyObject {

    /// Invoked when the account info has been retrieved
    func didGetAccountInfo()
}
