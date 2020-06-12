//
//  BitcoinAssetBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

public final class BitcoinAssetBalanceFetcher: AccountBalanceFetching {
    
    public typealias Bridge = BitcoinWalletBridgeAPI
        
    // MARK: - Exposed Properties
    
    public var balanceType: BalanceType {
        .nonCustodial
    }
    
    public var balance: Single<CryptoValue> {
        Single.zip(activeAccountAddresses, watchOnlyAddresses)
            .map { $0 + $1 }
            .flatMap(weak: self) { (self, activeAccounts) -> Single<BitcoinBalanceResponse> in
                self.client.balances(for: activeAccounts)
            }
            .map { balances -> CryptoValue in
                BitcoinBalances(addresses: balances).total
            }
    }
    
    public var balanceObservable: Observable<CryptoValue> {
        balanceRelay.asObservable()
    }
    
    public let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private var watchOnlyAddresses: Single<[String]> {
        repository.watchOnlyAddresses
    }
    
    private var activeAccountAddresses: Single<[String]> {
        repository.activeAccounts
            .map { $0.map(\.publicKey) }
    }
    
    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let bridge: Bridge
    private let client: APIClient
    private let repository: BitcoinWalletAccountRepository
    
    // MARK: - Setup
    
    public convenience init(bridge: Bridge) {
        self.init(bridge: bridge, client: APIClient())
    }
    
    init(bridge: Bridge, client: APIClient) {
        self.bridge = bridge
        self.client = client
        
        repository = BitcoinWalletAccountRepository(
            with: bridge
        )
        
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .flatMapLatest(weak: self) { (self, _) in
                self.balance.asObservable()
            }
            .bind(to: balanceRelay)
            .disposed(by: disposeBag)
    }
}

struct BitcoinBalances {
    
    let total: CryptoValue
    
    private let addresses: [String: CryptoValue]
    
    init(addresses: BitcoinBalanceResponse) {
        let addresses = addresses.compactMapValues { item -> CryptoValue? in
            CryptoValue(minor: "\(item.finalBalance)", cryptoCurreny: .bitcoin)
        }
        let totalBalance = try? addresses
            .values
            .reduce(CryptoValue.bitcoinZero, +)
        self.addresses = addresses
        self.total = totalBalance ?? CryptoValue.bitcoinZero
    }
    
    func balance(for account: BitcoinWalletAccount) -> CryptoValue? {
        addresses[account.publicKey]
    }
}
