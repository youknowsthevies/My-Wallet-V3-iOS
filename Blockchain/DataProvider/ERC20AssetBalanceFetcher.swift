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
import RxSwift
import RxRelay

final class ERC20AssetBalanceFetcher: AccountBalanceFetching {

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
        balanceRelay.asObservable()
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties

    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    private let assetAccountRepository: ERC20AssetAccountRepository<PaxToken>

    private unowned let reactiveWallet: ReactiveWalletAPI
    
    // MARK: - Setup

    init(wallet: EthereumWalletBridgeAPI = WalletManager.shared.wallet.ethereum,
         reactiveWallet: ReactiveWalletAPI = WalletManager.shared.reactiveWallet) {

        let service = ERC20AssetAccountDetailsService<PaxToken>(
            with: wallet,
            accountClient: ERC20AccountAPIClient<PaxToken>()
        )
        self.reactiveWallet = reactiveWallet
        assetAccountRepository = ERC20AssetAccountRepository(service: service)
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
            .bind(to: balanceRelay)
            .disposed(by: disposeBag)
    }
}
