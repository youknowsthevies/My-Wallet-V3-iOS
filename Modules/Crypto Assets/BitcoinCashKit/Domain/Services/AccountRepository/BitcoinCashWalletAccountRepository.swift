//
//  BitcoinCashWalletAccountRepository.swift
//  BitcoinCashKit
//
//  Created by Paulo on 12/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

final class BitcoinCashWalletAccountRepository: WalletAccountRepositoryAPI {
    
    typealias Account = BitcoinCashWalletAccount
    
    // MARK: - Properties
    
    var defaultAccount: Single<BitcoinCashWalletAccount> {
        bridge.defaultWallet
    }
    
    var accounts: Single<[BitcoinCashWalletAccount]> {
        bridge.wallets
    }
    
    var activeAccounts: Single<[BitcoinCashWalletAccount]> {
        accounts.map { accounts in
            accounts.filter(\.isActive)
        }
    }
    
    private let bridge: BitcoinCashWalletBridgeAPI
    
    // MARK: - Init
    
    init(bridge: BitcoinCashWalletBridgeAPI = resolve()) {
        self.bridge = bridge
    }
}

extension BitcoinCashWalletAccount {
    var isActive: Bool {
        !archived
    }
}
