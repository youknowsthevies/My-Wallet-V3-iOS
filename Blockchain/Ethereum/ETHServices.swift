//
//  ETHServiceProvider.swift
//  Blockchain
//
//  Created by Jack on 26/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import EthereumKit
import PlatformKit

struct ETHServices: ETHDependencies {
    let activity: ActivityItemEventServiceAPI
    let activityDetails: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails>
    let assetAccountRepository: EthereumAssetAccountRepository
    let qrMetadataFactory: EthereumQRMetadataFactory
    let repository: EthereumWalletAccountRepository
    let transactionService: EthereumHistoricalTransactionService

    init(wallet: Wallet = WalletManager.shared.wallet,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         simpleBuyOrdersAPI: SimpleBuyOrdersServiceAPI = SimpleBuyServiceProvider.default.ordersDetails,
         swapActivityAPI: SwapActivityServiceAPI = SwapServiceProvider.default.activity) {
        transactionService = EthereumHistoricalTransactionService(
            with: wallet.ethereum
        )
        activity = ActivityItemEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: EthereumTransactionalActivityItemEventsService(transactionsService: transactionService)
            ),
            buy: BuyActivityItemEventService(currency: .ethereum, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: EthereumSwapActivityItemEventsService(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
        activityDetails = .init(
            api: EthereumActivityItemEventDetailsFetcher(transactionService: transactionService)
        )
        assetAccountRepository = EthereumAssetAccountRepository(
            service: EthereumAssetAccountDetailsService(
                with: wallet.ethereum
            )
        )
        qrMetadataFactory = EthereumQRMetadataFactory()
        repository = EthereumWalletAccountRepository(with: wallet.ethereum)
    }
}
