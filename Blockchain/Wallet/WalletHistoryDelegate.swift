// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@objc protocol WalletHistoryDelegate: class {

    /// Method invoked when getting transaction history fails
    func didFailGetHistory(error: String?)

    /// Method invoked after getting BCH transaction history
    func didFetchBitcoinCashHistory()
}
