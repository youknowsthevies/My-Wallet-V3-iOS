//
//  ERC20AssetBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ERC20Kit
import EthereumKit
import PlatformKit
import RxRelay
import RxSwift

final class ERC20AssetBalanceFetcher<Token: ERC20Token>: CryptoAccountBalanceFetching {

    // MARK: - Exposed Properties

    var balanceType: BalanceType {
        .nonCustodial
    }

    var balance: Single<CryptoValue> {
        assetAccountRepository
            .currentAssetAccountDetails(fromCache: true)
            .asObservable()
            .asSingle()
            .map { details -> CryptoValue in
                details.balance
            }
    }

    var balanceObservable: Observable<CryptoValue> {
        _ = setup
        return balanceRelay.asObservable()
    }
    
    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.moneyValue
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private lazy var setup: Void = {
        Observable
            .combineLatest(
                reactiveWallet.waitUntilInitialized,
                balanceFetchTriggerRelay
            )
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .flatMapLatest(weak: self) { (self, _) in
                self.balance
                    .asObservable()
                    .materialize()
                    .filter { !$0.isStopEvent }
                    .dematerialize()
            }
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }()

    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    private let assetAccountRepository: ERC20AssetAccountRepository<Token>

    private unowned let reactiveWallet: ReactiveWalletAPI
    
    // MARK: - Setup

    init(wallet: EthereumWalletBridgeAPI = WalletManager.shared.wallet.ethereum,
         reactiveWallet: ReactiveWalletAPI = WalletManager.shared.reactiveWallet) {

        let service = ERC20AssetAccountDetailsService<Token>(
            with: wallet,
            accountClient: ERC20AccountAPIClient<Token>()
        )
        self.reactiveWallet = reactiveWallet
        assetAccountRepository = ERC20AssetAccountRepository(service: service)
    }
}
