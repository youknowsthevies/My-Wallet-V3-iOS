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
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         swapActivityAPI: SwapActivityServiceAPI = resolve()) {
        historicalTransactionService = AnyERC20HistoricalTransactionService<TetherToken>(bridge: wallet.ethereum)
        let assetAccountService = ERC20AssetAccountDetailsService<TetherToken>(
            with: wallet.ethereum,
            accountClient: ERC20AccountAPIClient<TetherToken>()
        )
        assetAccountRepository = ERC20AssetAccountRepository(service: assetAccountService)
    }
}
