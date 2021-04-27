//
//  BitcoinWalletAccountRepository.swift
//  BitcoinKit
//
//  Created by kevinwu on 2/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

final class BitcoinWalletAccountRepository {

    // MARK: - Properties

    var defaultAccount: Single<BitcoinWalletAccount> {
        bridge.defaultWallet
    }
    
    var accounts: Single<[BitcoinWalletAccount]> {
        bridge.wallets
    }
    
    var activeAccounts: Single<[BitcoinWalletAccount]> {
        accounts.map { accounts in
            accounts.filter(\.isActive)
        }
    }

    private let bridge: BitcoinWalletBridgeAPI

    // MARK: - Init

    init(bridge: BitcoinWalletBridgeAPI = resolve()) {
        self.bridge = bridge
    }
}
