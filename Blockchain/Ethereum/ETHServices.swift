//
//  ETHServiceProvider.swift
//  Blockchain
//
//  Created by Jack on 26/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import PlatformKit

struct ETHServices: ETHDependencies {
    let activity: ActivityItemEventFetcherAPI
    let activityDetails: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails>
    let assetAccountRepository: EthereumAssetAccountRepository
    let qrMetadataFactory: EthereumQRMetadataFactory
    let repository: EthereumWalletAccountRepository
    let transactionService: EthereumHistoricalTransactionService

    init(wallet: Wallet = WalletManager.shared.wallet,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings) {
        transactionService = EthereumHistoricalTransactionService(
            with: wallet.ethereum
        )
        activity = EthereumActivityItemEventFetcher(
            swapActivityEventService: .init(
                service: SwapActivityService(
                    authenticationService: authenticationService,
                    fiatCurrencyProvider: fiatCurrencyService
                )
            ),
            transactionalActivityEventService: .init(
                transactionsService: transactionService
            ),
            fiatCurrencyProvider: fiatCurrencyService
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
