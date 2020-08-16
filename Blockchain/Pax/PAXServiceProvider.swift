//
//  PaxServiceProvider.swift
//  Blockchain
//
//  Created by Jack on 12/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift

protocol PAXDependencies {
    var assetAccountRepository: ERC20AssetAccountRepository<PaxToken> { get }
    var historicalTransactionService: AnyERC20HistoricalTransactionService<PaxToken> { get }
    var paxService: ERC20Service<PaxToken> { get }
    var walletService: EthereumWalletServiceAPI { get }
    var feeService: AnyCryptoFeeService<EthereumTransactionFee> { get }
}

struct PAXServices: PAXDependencies {
    let assetAccountRepository: ERC20AssetAccountRepository<PaxToken>
    let historicalTransactionService: AnyERC20HistoricalTransactionService<PaxToken>
    let paxService: ERC20Service<PaxToken>
    let walletService: EthereumWalletServiceAPI
    let feeService: AnyCryptoFeeService<EthereumTransactionFee>

    init(assetAccountRepository: ERC20AssetAccountRepository<PaxToken> = resolve(),
         wallet: Wallet = WalletManager.shared.wallet,
         feeService: AnyCryptoFeeService<EthereumTransactionFee> = AnyCryptoFeeService(service: CryptoFeeService<EthereumTransactionFee>.shared),
         walletService: EthereumWalletServiceAPI = EthereumWalletService.shared) {
        self.assetAccountRepository = assetAccountRepository
        self.feeService = feeService
        self.historicalTransactionService = AnyERC20HistoricalTransactionService<PaxToken>(bridge: wallet.ethereum)
        let ethereumAssetAccountRepository: EthereumAssetAccountRepository = EthereumAssetAccountRepository(
            service: EthereumAssetAccountDetailsService(
                with: wallet.ethereum
            )
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
        feeService: AnyCryptoFeeService(service: CryptoFeeService<EthereumTransactionFee>.shared),
        walletAccountRepository: ETHServiceProvider.shared.repository,
        transactionBuildingService: EthereumTransactionBuildingService.shared,
        transactionSendingService: EthereumTransactionSendingService.shared,
        transactionValidationService: EthereumTransactionValidationService.shared
    )
}

extension EthereumTransactionSendingService {
    static let shared = EthereumTransactionSendingService(
        with: WalletManager.shared.wallet.ethereum,
        feeService: AnyCryptoFeeService(service: CryptoFeeService<EthereumTransactionFee>.shared),
        transactionBuilder: EthereumTransactionBuilder.shared,
        transactionSigner: EthereumTransactionSigner.shared,
        transactionEncoder: EthereumTransactionEncoder.shared
    )
}

extension EthereumTransactionValidationService {
    static let shared = EthereumTransactionValidationService(
        with: AnyCryptoFeeService(service: CryptoFeeService<EthereumTransactionFee>.shared),
        repository: ETHServiceProvider.shared.assetAccountRepository
    )
}

extension EthereumTransactionBuildingService {
    static let shared = EthereumTransactionBuildingService(
        with: AnyCryptoFeeService(service: CryptoFeeService<EthereumTransactionFee>.shared),
        repository: ETHServiceProvider.shared.assetAccountRepository
    )
}
