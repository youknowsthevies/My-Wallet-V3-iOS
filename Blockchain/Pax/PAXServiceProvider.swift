//
//  PaxServiceProvider.swift
//  Blockchain
//
//  Created by Jack on 12/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import EthereumKit
import ERC20Kit

protocol PAXDependencies {
    var activity: AnyERC20ActivityItemEventFetcher<PaxToken> { get }
    var assetAccountRepository: ERC20AssetAccountRepository<PaxToken> { get }
    var historicalTransactionService: AnyERC20HistoricalTransactionService<PaxToken> { get }
    var paxService: ERC20Service<PaxToken> { get }
    var walletService: EthereumWalletServiceAPI { get }
    var feeService: EthereumFeeServiceAPI { get }
}

struct PAXServices: PAXDependencies {
    let assetAccountRepository: ERC20AssetAccountRepository<PaxToken>
    let historicalTransactionService: AnyERC20HistoricalTransactionService<PaxToken>
    let paxService: ERC20Service<PaxToken>
    let walletService: EthereumWalletServiceAPI
    let feeService: EthereumFeeServiceAPI
    let activity: AnyERC20ActivityItemEventFetcher<PaxToken>
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         feeService: EthereumFeeServiceAPI = EthereumFeeService.shared,
         walletService: EthereumWalletServiceAPI = EthereumWalletService.shared,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared) {
        self.feeService = feeService
        let service = ERC20AssetAccountDetailsService<PaxToken>(with: wallet.ethereum, accountClient: ERC20AccountAPIClient<PaxToken>())
        self.assetAccountRepository = ERC20AssetAccountRepository(service: service)
        self.historicalTransactionService = AnyERC20HistoricalTransactionService<PaxToken>(bridge: wallet.ethereum)
        let ethereumAssetAccountRepository: EthereumAssetAccountRepository = EthereumAssetAccountRepository(
            service: EthereumAssetAccountDetailsService(
                with: wallet.ethereum
            )
        )
        
        self.activity = AnyERC20ActivityItemEventFetcher<PaxToken>.init(
            swapActivityEventService: .init(
                service: SwapActivityService(
                    authenticationService: authenticationService,
                    fiatCurrencyProvider: fiatCurrencyService
                )
            ),
            transactionalActivityEventService: .init(
                transactionsService: historicalTransactionService
            ),
            fiatCurrencyProvider: fiatCurrencyService
        )
        
        self.paxService = ERC20Service<PaxToken>(
            with: wallet.ethereum,
            assetAccountRepository: assetAccountRepository,
            ethereumAssetAccountRepository: ethereumAssetAccountRepository,
            feeService: feeService
        )
        self.walletService = walletService
    }
}

final class PAXServiceProvider {
    static let shared: PAXServiceProvider = .init(services: PAXServices())

    let services: PAXDependencies
    
    private let disposables = CompositeDisposable()

    init(services: PAXDependencies) {
        self.services = services
    }
}

extension EthereumWalletService {
    public static let shared = EthereumWalletService(
        with: WalletManager.shared.wallet.ethereum,
        feeService: EthereumFeeService.shared,
        walletAccountRepository: ETHServiceProvider.shared.repository,
        transactionBuildingService: EthereumTransactionBuildingService.shared,
        transactionSendingService: EthereumTransactionSendingService.shared,
        transactionValidationService: EthereumTransactionValidationService.shared
    )
}

extension EthereumTransactionSendingService {
    static let shared = EthereumTransactionSendingService(
        with: WalletManager.shared.wallet.ethereum,
        feeService: EthereumFeeService.shared,
        transactionBuilder: EthereumTransactionBuilder.shared,
        transactionSigner: EthereumTransactionSigner.shared,
        transactionEncoder: EthereumTransactionEncoder.shared
    )
}

extension EthereumTransactionValidationService {
    static let shared = EthereumTransactionValidationService(
        with: EthereumFeeService.shared,
        repository: ETHServiceProvider.shared.assetAccountRepository
    )
}

extension EthereumTransactionBuildingService {
    static let shared = EthereumTransactionBuildingService(
        with: EthereumFeeService.shared, 
        repository: ETHServiceProvider.shared.assetAccountRepository
    )
}
