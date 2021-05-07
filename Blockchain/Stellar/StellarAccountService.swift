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
    
    var balance: Single<CryptoValue> {
        currentStellarAccount(fromCache: false)
            .map(\.assetAccount.balance)
    }
    
    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }
    
    var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .stellar))
    }
    
    var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }
    
    var balanceObservable: Observable<CryptoValue> {
        balanceRelay.asObservable()
    }

    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.map { MoneyValue(cryptoValue: $0) }
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()

    private let configurationService: StellarConfigurationAPI
    private let repository: StellarWalletAccountRepositoryAPI
    private let privateAccountCache: CachedValue<StellarAccount>
    private let balanceRelay = PublishRelay<CryptoValue>()
    private var disposeBag = DisposeBag()
    private var service: Single<AccountService> {
        configurationService.configuration.map(\.sdk.accounts)
    }

    init(
        configurationService: StellarConfigurationAPI,
        repository: StellarWalletAccountRepositoryAPI
    ) {
        self.configurationService = configurationService
        self.repository = repository
        privateAccountCache = CachedValue<StellarAccount>(
            configuration: CachedValueConfiguration(
                refreshType: .periodic(seconds: 60),
                flushNotificationName: .logout,
                fetchNotificationName: .login
            )
        )

        privateAccountCache.setFetch(weak: self) { (self) -> Single<StellarAccount> in
            guard let defaultXLMAccount = self.repository.defaultAccount else {
                return Single.error(StellarAccountError.noXLMAccount)
            }
            return self.accountDetails(for: defaultXLMAccount.publicKey)
        }

        balanceFetchTriggerRelay
            .flatMapLatest(weak: self) { (self, _) in
                self.balance.asObservable()
            }
            .catchErrorJustReturn(CryptoValue.stellarZero)
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }

    // MARK: Public Functions
    
    func clear() {
        self.disposeBag = DisposeBag()
        privateAccountCache
            .invalidate
            .subscribe()
            .disposed(by: disposeBag)
    }

    func currentStellarAccount(fromCache: Bool) -> Single<StellarAccount> {
        fromCache ? privateAccountCache.valueSingle : privateAccountCache.fetchValue
    }

    private func accountResponse(for accountID: String) -> Single<AccountResponse> {
        service.flatMap(weak: self) { (self, service) -> Single<AccountResponse> in
            Single<AccountResponse>.create { event -> Disposable in
                service.getAccountDetails(accountId: accountID, response: { response -> (Void) in
                    switch response {
                    case .success(details: let details):
                        event(.success(details))
                    case .failure(error: let error):
                        event(.error(error.toStellarServiceError()))
                    }
                })
                return Disposables.create()
            }
        }
    }

    private func accountDetails(for accountID: String) -> Single<StellarAccount> {
        accountResponse(for: accountID)
            .map(\.stellarAccount)
            .catchError { error in
                switch error {
                case StellarAccountError.noDefaultAccount:
                    // If the network call to Horizon fails due to there not being a default account (i.e. account is not yet
                    // funded), catch that error and return a StellarAccount with 0 balance
                    return Single.just(StellarAccount.unfundedAccount(accountId: accountID))
                default:
                    throw error
                }
            }
    }
}

// MARK: - Extension

extension AccountResponse {
    fileprivate var stellarAccount: StellarAccount {
        let totalBalanceDecimal = balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
        let majorString = (totalBalanceDecimal as NSDecimalNumber).description(withLocale: Locale.Posix)
        let totalBalance = CryptoValue.stellar(major: majorString) ?? CryptoValue.stellarZero
        let assetAddress = AssetAddressFactory.create(
            fromAddressString: accountId,
            assetType: .stellar
        )
        let assetAccount = AssetAccount(
            index: 0,
            address: assetAddress,
            balance: totalBalance,
            name: CryptoCurrency.stellar.defaultWalletName
        )
        return StellarAccount(
            identifier: accountId,
            assetAccount: assetAccount,
            sequence: sequenceNumber,
            subentryCount: subentryCount
        )
    }
}
