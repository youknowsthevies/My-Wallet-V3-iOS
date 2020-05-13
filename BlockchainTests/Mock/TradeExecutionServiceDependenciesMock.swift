//
//  TradeExecutionServiceDependenciesMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import stellarsdk

@testable import Blockchain
@testable import PlatformKit
import BitcoinKit
import StellarKit
import EthereumKit
import ERC20Kit

class StellarOperationMock: StellarOperationsAPI {
    var operations: Observable<[Blockchain.StellarOperation]> = Observable.just([])
    
    func isStreaming() -> Bool {
        return true
    }
    
    func end() {
        
    }
    
    func clear() {
        
    }
}

final class PriceServiceMock: PriceServiceAPI {

    var historicalPriceSeries: HistoricalPriceSeries = HistoricalPriceSeries(currency: .bitcoin, prices: [.empty])
    var priceInFiatValue: PriceInFiatValue = PriceInFiat.empty.toPriceInFiatValue(fiatCurrency: .USD)

    func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency) -> Single<PriceInFiatValue> {
        .just(priceInFiatValue)
    }

    func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency, at date: Date) -> Single<PriceInFiatValue> {
        .just(priceInFiatValue)
    }

    func priceSeries(within window: PriceWindow, of cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency) -> Single<HistoricalPriceSeries> {
        .just(historicalPriceSeries)
    }
}

class TradeExecutionServiceDependenciesMock: TradeExecutionServiceDependenciesAPI {
    var assetAccountRepository: Blockchain.AssetAccountRepositoryAPI = AssetAccountRepositoryMock()
    var feeService: FeeServiceAPI = FeeServiceMock()
    var stellar: StellarDependenciesAPI = StellarDependenciesMock()
    var erc20Service: AnyERC20Service<PaxToken> = AnyERC20Service<PaxToken>(PaxERC20ServiceMock())
    var erc20AccountRepository: AnyERC20AssetAccountRepository<PaxToken> = AnyERC20AssetAccountRepository<PaxToken>(ERC20AssetAccountRepositoryMock())
    var ethereumWalletService: EthereumWalletServiceAPI = EthereumWalletServiceMock()
}

class FeeServiceMock: FeeServiceAPI {
    var bitcoin: Single<BitcoinTransactionFee> = Single.error(NSError())
    var ethereum: Single<EthereumTransactionFee> = Single.error(NSError())
    var stellar: Single<StellarTransactionFee> = Single.error(NSError())
    var bitcoinCash: Single<BitcoinCashTransactionFee> = Single.error(NSError())
}

class StellarDependenciesMock: StellarDependenciesAPI {
    var accounts: StellarAccountAPI = StellarAccountMock()
    var ledger: StellarLedgerAPI = StellarLedgerMock()
    var operation: StellarOperationsAPI = StellarOperationMock()
    var transaction: StellarTransactionAPI = StellarTransactionMock()
    var limits: StellarTradeLimitsAPI = StellarTradeLimitsMock()
    var repository: StellarWalletAccountRepositoryAPI = StellarWalletAccountRepositoryMock()
    var prices: PriceServiceAPI = PriceServiceMock()
    var walletActionEventBus: WalletActionEventBus = WalletActionEventBus()
    var feeService: StellarFeeServiceAPI = StellarFeeServiceMock()
}
