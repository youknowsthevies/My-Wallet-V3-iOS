//
//  BitcoinCashWalletBridgeAPI.swift
//  BitcoinCashKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol BitcoinCashWalletBridgeAPI {
    var defaultWallet: Single<BitcoinCashWalletAccount> { get }
    var wallets: Single<[BitcoinCashWalletAccount]> { get }
}
