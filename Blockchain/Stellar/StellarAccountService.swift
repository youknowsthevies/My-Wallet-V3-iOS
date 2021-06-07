// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit
import RxCocoa
import RxSwift
import StellarKit
import stellarsdk
import ToolKit

class StellarAccountService: StellarAccountAPI {

    // MARK: AccountBalanceFetching

    var accountType: SingleAccountType {
        .nonCustodial
    }

    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney.asObservable()
    }

    var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .stellar))
    }

    var balanceMoney: Single<MoneyValue> {
        fetchStellarAccount.map(\.balance).moneyValue
    }

    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceRelay.asObservable()
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()

    private let repository: StellarWalletAccountRepositoryAPI
    private let privateAccountCache: CachedValue<StellarAccountDetails>
    private let detailsService: StellarAccountDetailsServiceAPI
    private let balanceRelay = PublishRelay<MoneyValue>()
    private var disposeBag = DisposeBag()

    init(
        detailsService: StellarAccountDetailsServiceAPI = resolve(),
        repository: StellarWalletAccountRepositoryAPI
    ) {
        self.repository = repository
        self.detailsService = detailsService
        privateAccountCache = CachedValue<StellarAccountDetails>(
            configuration: CachedValueConfiguration(
                refreshType: .periodic(seconds: 60),
                flushNotificationName: .logout,
                fetchNotificationName: .login
            )
        )

        privateAccountCache.setFetch(weak: self) { (self) -> Single<StellarAccountDetails> in
            guard let defaultXLMAccount = self.repository.defaultAccount else {
                return Single.error(StellarAccountError.noXLMAccount)
            }
            return self.detailsService.accountDetails(for: defaultXLMAccount.publicKey)
        }

        balanceFetchTriggerRelay
            .flatMapLatest(weak: self) { (self, _) in
                self.balanceMoney.asObservable()
            }
            .catchErrorJustReturn(CryptoValue.stellarZero.moneyValue)
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }

    // MARK: Public Functions

    var fetchStellarAccount: Single<StellarAccountDetails> {
        privateAccountCache.fetchValue
    }
}
