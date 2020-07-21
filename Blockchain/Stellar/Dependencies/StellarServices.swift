//
//  StellarServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import RxSwift
import StellarKit

struct StellarServices: StellarDependenciesAPI {
    let accounts: StellarAccountAPI
    let feeService: StellarFeeServiceAPI
    let ledger: StellarLedgerAPI
    let limits: StellarTradeLimitsAPI
    let operation: StellarOperationsAPI
    let prices: PriceServiceAPI
    let repository: StellarWalletAccountRepositoryAPI
    let transaction: StellarTransactionAPI
    let walletActionEventBus: WalletActionEventBus

    init(
        configurationService: StellarConfigurationAPI = StellarConfigurationService.shared,
        wallet: Wallet = WalletManager.shared.wallet,
        eventBus: WalletActionEventBus = WalletActionEventBus.shared,
        xlmFeeService: StellarFeeServiceAPI = StellarFeeService.shared
    ) {
        walletActionEventBus = eventBus
        repository = StellarWalletAccountRepository(with: wallet)
        ledger = StellarLedgerService(
            configurationService: configurationService,
            feeService: xlmFeeService
        )
        accounts = StellarAccountService(
            configurationService: configurationService,
            ledgerService: ledger,
            repository: repository
        )
        transaction = StellarTransactionService(
            configurationService: configurationService,
            accounts: accounts,
            repository: repository
        )
        operation = StellarOperationService(
            configurationService: configurationService,
            repository: repository
        )
        prices = PriceService()
        limits = StellarTradeLimitsService(
            ledgerService: ledger,
            accountsService: accounts
        )
        feeService = xlmFeeService
    }
}
