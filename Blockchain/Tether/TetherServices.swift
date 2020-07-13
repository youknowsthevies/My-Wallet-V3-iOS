//
//  TetherServices.swift
//  Blockchain
//
//  Created by Paulo on 01/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import ERC20Kit
import PlatformKit

struct TetherServices: TetherDependencies {
    let assetAccountRepository: ERC20AssetAccountRepository<TetherToken>
    let activity: ActivityItemEventServiceAPI
    let historicalTransactionService: AnyERC20HistoricalTransactionService<TetherToken>
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         simpleBuyOrdersAPI: OrdersServiceAPI = ServiceProvider.default.ordersDetails,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         swapActivityAPI: SwapActivityServiceAPI = SwapServiceProvider.default.activity) {
        historicalTransactionService = AnyERC20HistoricalTransactionService<TetherToken>(bridge: wallet.ethereum)
        activity = ActivityItemEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: AnyERC20TransactionalActivityItemEventsService<TetherToken>(transactionsService: historicalTransactionService)
            ),
            buy: BuyActivityItemEventService(currency: .tether, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: AnyERC20SwapActivityItemEventsService<TetherToken>(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
        let assetAccountService = ERC20AssetAccountDetailsService<TetherToken>(
            with: wallet.ethereum,
            accountClient: ERC20AccountAPIClient<TetherToken>()
        )
        assetAccountRepository = ERC20AssetAccountRepository(service: assetAccountService)
    }
}
