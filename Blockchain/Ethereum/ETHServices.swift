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

    let assetAccountRepository: EthereumAssetAccountRepository
    let qrMetadataFactory: EthereumQRMetadataFactory
    let repository: EthereumWalletAccountRepository
    let transactionService: EthereumHistoricalTransactionService

    init(wallet: Wallet = WalletManager.shared.wallet,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings) {
        transactionService = EthereumHistoricalTransactionService(
            with: wallet.ethereum
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
