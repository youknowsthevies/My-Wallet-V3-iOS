//
//  StellarServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import RxSwift
import StellarKit

struct StellarServices: StellarDependenciesAPI {
    let accounts: StellarAccountAPI
    let feeService: AnyCryptoFeeService<StellarTransactionFee>
    let ledger: StellarLedgerServiceAPI
    let limits: StellarTradeLimitsAPI
    let operation: StellarOperationsAPI
    let prices: PriceServiceAPI
    let repository: StellarWalletAccountRepositoryAPI
    let transaction: StellarTransactionAPI
    let walletActionEventBus: WalletActionEventBus

    init(
        configurationService: StellarConfigurationAPI = resolve(),
        wallet: Wallet = WalletManager.shared.wallet,
        eventBus: WalletActionEventBus = WalletActionEventBus.shared,
        feeService: AnyCryptoFeeService<StellarTransactionFee> = resolve(),
        ledger: StellarLedgerServiceAPI = resolve(),
        repository: StellarWalletAccountRepositoryAPI = resolve()
    ) {
        walletActionEventBus = eventBus
        self.repository = repository
        self.ledger = ledger
        self.feeService = feeService
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
    }
}
