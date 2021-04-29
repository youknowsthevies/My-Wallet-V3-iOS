// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Provider protocol for a source account on the send screen
protocol SendSourceAccountProviding {
    var accounts: [SendSourceAccount] { get }
    func account(by index: Int) -> SendSourceAccount
    var `default`: SendSourceAccount { get }
}

extension SendSourceAccountProviding {
    func account(by index: Int) -> SendSourceAccount {
        accounts[index]
    }
    
    var `default`: SendSourceAccount {
        account(by: 0)
    }
}

// MARK: - Asset Specific

class EtherSendSourceAccountProvider: SendSourceAccountProviding {
    let accounts = [SendSourceAccount(label: CryptoCurrency.ethereum.defaultWalletName)]
}
