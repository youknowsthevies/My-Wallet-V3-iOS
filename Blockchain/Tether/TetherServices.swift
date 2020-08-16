//
//  TetherServices.swift
//  Blockchain
//
//  Created by Paulo on 01/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BuySellKit
import ERC20Kit
import PlatformKit

struct TetherServices: TetherDependencies {
    let assetAccountRepository: ERC20AssetAccountRepository<TetherToken>
    let historicalTransactionService: AnyERC20HistoricalTransactionService<TetherToken>
    
    init(assetAccountRepository: ERC20AssetAccountRepository<TetherToken> = resolve(),
         wallet: Wallet = WalletManager.shared.wallet) {
        self.assetAccountRepository = assetAccountRepository
        historicalTransactionService = AnyERC20HistoricalTransactionService<TetherToken>(bridge: wallet.ethereum)
    }
}
