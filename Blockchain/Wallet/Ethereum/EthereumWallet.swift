//
//  EthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import ERC20Kit
import EthereumKit
import Foundation
import PlatformKit
import RxRelay
import RxSwift

class EthereumWallet: NSObject {
    
    typealias Dispatcher = EthereumJSInteropDispatcherAPI & EthereumJSInteropDelegateAPI
    
    typealias WalletAPI = LegacyEthereumWalletAPI & LegacyWalletAPI & MnemonicAccessAPI
    
    var balanceObservable: Observable<CryptoValue> {
        balanceRelay.asObservable()
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()

    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    
    var delegate: EthereumJSInteropDelegateAPI {
        dispatcher
    }

    weak var reactiveWallet: ReactiveWalletAPI!
    
    @available(*, deprecated, message: "making this  so tests will compile")
    var interopDispatcher: EthereumJSInteropDispatcherAPI {
        dispatcher
    }
    
    @available(*, deprecated, message: "Please don't use this. It's here only to support legacy code")
    @objc var legacyEthBalance: NSDecimalNumber = 0
    
    private lazy var credentialsProvider: WalletCredentialsProviding = WalletManager.shared.legacyRepository
    private weak var wallet: WalletAPI?
    private let walletOptionsService: WalletOptionsAPI
    
    /// NOTE: This is to fix flaky tests - interaction with `Wallet` should be performed on the main scheduler
    private let schedulerType: SchedulerType
    
    /// This is lazy because we got a massive retain cycle, and injecting using `EthereumWallet` initializer
    /// overflows the function stack with initializers that call one another
    private lazy var dependencies: ETHDependencies = ETHServiceProvider.shared.services

    private static let defaultPAXAccount = ERC20TokenAccount(
        label: LocalizationConstants.SendAsset.myPaxWallet,
        contractAddress: PaxToken.contractAddress.publicKey,
        hasSeen: false,
        transactionNotes: [String: String]()
    )

    private var ethereumAccountExists: Bool?

    private let dispatcher: Dispatcher
    
    @objc convenience init(legacyWallet: Wallet) {
        self.init(schedulerType: MainScheduler.instance, wallet: legacyWallet)
    }
    
    convenience init(schedulerType: SchedulerType, legacyWallet: Wallet) {
        self.init(schedulerType: schedulerType, wallet: legacyWallet)
    }
    
    init(schedulerType: SchedulerType = MainScheduler.instance,
         walletOptionsService: WalletOptionsAPI = WalletService.shared,
         wallet: WalletAPI,
         dispatcher: Dispatcher = EthereumJSInteropDispatcher.shared) {
        self.schedulerType = schedulerType
        self.walletOptionsService = walletOptionsService
        self.wallet = wallet
        self.dispatcher = dispatcher
        super.init()
    }
    
    @objc func setup(with context: JSContext) {
        context.setJsFunction(named: "objc_on_didGetERC20TokensAsync" as NSString) { [weak self] erc20TokenAccounts in
            self?.delegate.didGetERC20Tokens(erc20TokenAccounts)
        }
        context.setJsFunction(named: "objc_on_error_gettingERC20TokensAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetERC20Tokens(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_didSetERC20TokensAsync" as NSString) { [weak self] erc20TokenAccounts in
            self?.delegate.didSaveERC20Tokens()
        }
        context.setJsFunction(named: "objc_on_error_settingERC20TokensAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToSaveERC20Tokens(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_get_ether_address_success" as NSString) { [weak self] address in
            self?.delegate.didGetAddress(address)
        }
        context.setJsFunction(named: "objc_on_get_ether_address_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetAddress(errorMessage: errorMessage)
        }

        context.setJsFunction(named: "objc_on_didGetEtherAccountsAsync" as NSString) { [weak self] accounts in
            self?.delegate.didGetAccounts(accounts)
        }
        context.setJsFunction(named: "objc_on_error_gettingEtherAccountsAsync" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToGetAccounts(errorMessage: errorMessage)
        }
        
        context.setJsFunction(named: "objc_on_recordLastTransactionAsync_success" as NSString) { [weak self] in
            self?.delegate.didRecordLastTransaction()
        }
        context.setJsFunction(named: "objc_on_recordLastTransactionAsync_error" as NSString) { [weak self] errorMessage in
            self?.delegate.didFailToRecordLastTransaction(errorMessage: errorMessage)
        }
    }
    
    @objc func walletDidLoad() {
        Observable
            .combineLatest(
                reactiveWallet.waitUntilInitialized,
                balanceFetchTriggerRelay
            )
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .flatMap(weak: self) { (self, _) in
                self.walletLoaded()
                    .catchError { error in
                        switch error {
                        case SecondPasswordError.userDismissed:
                            // User dismissed SecondPassword screen.
                            return .empty()
                        default:
                            throw error
                        }
                    }
                    .andThen(Observable.just(()))
            }
            .flatMapLatest(weak: self) { (self, _) in
                self.balance
                    .asObservable()
                    .materialize()
                    .filter { !$0.isStopEvent }
                    .dematerialize()
            }
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }

    func walletLoaded() -> Completable {
        guard let wallet = wallet else {
            return .empty()
        }
        ethereumAccountExists = wallet.checkIfEthereumAccountExists()
        return saveDefaultPAXAccountIfNeeded()
            .subscribeOn(MainScheduler.asyncInstance)
    }
    
    private func saveDefaultPAXAccountIfNeeded() -> Completable {
        erc20TokenAccounts
            .flatMapCompletable(weak: self) { (self, tokenAccounts) -> Completable in
                guard tokenAccounts[PaxToken.metadataKey] == nil else {
                    return Completable.empty()
                }
                return self.saveDefaultPAXAccount().asCompletable()
            }
    }
    
    private func saveDefaultPAXAccount() -> Single<ERC20TokenAccount> {
        let paxAccount = EthereumWallet.defaultPAXAccount
        return save(erc20TokenAccounts: [ PaxToken.metadataKey : paxAccount ])
            .asObservable()
            .flatMap(weak: self) { (self, _) -> Observable<ERC20TokenAccount> in
                Observable.just(paxAccount)
            }
            .asSingle()
    }
}

extension EthereumWallet: ERC20BridgeAPI { 
    func tokenAccount(for key: String) -> Single<ERC20TokenAccount?> {
        erc20TokenAccounts
            .flatMap { tokenAccounts -> Single<ERC20TokenAccount?> in
                Single.just(tokenAccounts[key])
            }
    }
    
    func save(erc20TokenAccounts: [String: ERC20TokenAccount]) -> Single<Void> {
        secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<Void> in
                self.save(
                    erc20TokenAccounts: erc20TokenAccounts,
                    secondPassword: secondPassword
                )
            }
    }
    
    var erc20TokenAccounts: Single<[String: ERC20TokenAccount]> {
        secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[String: ERC20TokenAccount]> in
                self.erc20TokenAccounts(secondPassword: secondPassword)
        }
    }

    func memo(for transactionHash: String, tokenKey: String) -> Single<String?> {
        erc20TokenAccounts
            .map { tokenAccounts -> ERC20TokenAccount? in
                tokenAccounts[tokenKey]
            }
            .map { tokenAccount -> String? in
                tokenAccount?.transactionNotes[transactionHash]
            }
    }
    
    func save(transactionMemo: String, for transactionHash: String, tokenKey: String) -> Single<Void> {
        erc20TokenAccounts
            .flatMap { tokenAccounts -> Single<([String: ERC20TokenAccount], ERC20TokenAccount)> in
                guard let tokenAccount = tokenAccounts[tokenKey] else {
                    throw WalletError.failedToSaveMemo
                }
                return Single.just((tokenAccounts, tokenAccount))
            }
            .flatMap(weak: self) { (self, tuple) -> Single<Void> in
                var (tokenAccounts, tokenAccount) = tuple
                _ = tokenAccounts.removeValue(forKey: tokenKey)
                tokenAccount.update(memo: transactionMemo, for: transactionHash)
                tokenAccounts[tokenKey] = tokenAccount
                return self.save(erc20TokenAccounts: tokenAccounts)
            }
    }
    
    private func save(erc20TokenAccounts: [String: ERC20TokenAccount], secondPassword: String?) -> Single<Void> {
        Single.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            guard let jsonData = try? JSONEncoder().encode(erc20TokenAccounts) else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }
            wallet.saveERC20Tokens(with: nil, tokensJSONString: jsonData.string, success: {
                observer(.success(()))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
    }
    
    private func erc20TokenAccounts(secondPassword: String? = nil) -> Single<[String: ERC20TokenAccount]> {
        Single<[String: [String: Any]]>.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.erc20Tokens(with: secondPassword, success: { erc20Tokens in
                observer(.success(erc20Tokens))
            }, error: { errorMessage in
                observer(.error(WalletError.unknown))
            })
            return Disposables.create()
        })
        .flatMap { erc20Accounts -> Single<[String: ERC20TokenAccount]> in
            let accounts: [String: ERC20TokenAccount] = erc20Accounts.decodeJSONObjects(type: ERC20TokenAccount.self)
            return Single.just(accounts)
        }
    }
}

extension EthereumWallet: EthereumWalletBridgeAPI {

    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        let saveMemo: Completable = Completable.create { completable in
            self.wallet?.setEthereumMemo(for: transactionHash, memo: memo)
            completable(.completed)
            return Disposables.create()
        }
        return reactiveWallet
            .waitUntilInitialized
            .flatMap { saveMemo.asObservable() }
            .asCompletable()
    }

    func memo(for transactionHash: String) -> Single<String?> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    return Disposables.create()
                }
                wallet.getEthereumMemo(
                    for: transactionHash,
                    success: { (memo) in
                        observer(.success(memo))
                    },
                    error: { (error) in
                        observer(.error(WalletError.notInitialized))
                    }
                )
                return Disposables.create()
            }
    }

    var balanceType: BalanceType {
        .nonCustodial
    }
    
    var history: Single<Void> {
        fetchHistory(fromCache: false)
    }
    
    var balance: Single<CryptoValue> {
        secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<CryptoValue> in
                self.fetchBalance(secondPassword: secondPassword)
        }
    }
    
    var name: Single<String> {
        secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                self.label(secondPassword: secondPassword)
            }
    }

    var address: Single<EthereumKit.EthereumAddress> {
        secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                self.address(secondPassword: secondPassword)
            }
            .map { EthereumKit.EthereumAddress(stringLiteral: $0) }
    }
    
    var account: Single<EthereumAssetAccount> {
        wallets
            .flatMap { accounts -> Single<EthereumAssetAccount> in
                guard let defaultAccount = accounts.first else {
                    throw WalletError.unknown
                }
                let account = EthereumAssetAccount(
                    walletIndex: 0,
                    accountAddress: defaultAccount.publicKey,
                    name: defaultAccount.label ?? ""
                )
                return Single.just(account)
            }
    }
    
    /// Streams the nonce of the address
    var nonce: Single<BigUInt> {
        dependencies
            .assetAccountRepository
            .assetAccountDetails
            .map { BigUInt(integerLiteral: $0.nonce) }
    }
    
    /// Streams `true` if there is a prending transaction
    var isWaitingOnTransaction: Single<Bool> {
        dependencies.transactionService
            .fetchTransactions()
            .map { $0.contains(where: { $0.state == .pending }) }
    }

    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.recordLastEthereumTransaction(
                    transactionHash: transaction.transactionHash,
                    success: {
                        observer(.success(transaction))
                    },
                    error: { errorMessage in
                        observer(.error(WalletError.unknown))
                    }
                )
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }

    func fetchHistory() -> Single<Void> {
        fetchHistory(fromCache: false)
    }

    private func fetchBalance(secondPassword: String? = nil) -> Single<CryptoValue> {
        dependencies.assetAccountRepository.assetAccountDetails
            .map { $0.balance }
            // TODO: This side effect is necessary for backward compat. since the relevant JS logic has been removed
            .do(onSuccess: { [weak self] cryptoValue in
                self?.legacyEthBalance = NSDecimalNumber(decimal: cryptoValue.majorValue)
            })
    }
    
    private func accounts(secondPassword: String? = nil) -> Single<EthereumAssetAccount> {
        wallets.flatMap { wallets -> Single<EthereumAssetAccount> in
            guard let defaultAccount = wallets.first else {
                throw WalletError.unknown
            }
            let account = EthereumAssetAccount(
                walletIndex: 0,
                accountAddress: defaultAccount.publicKey,
                name: defaultAccount.label ?? ""
            )
            return Single.just(account)
        }
    }
    
    private func label(secondPassword: String? = nil) -> Single<String> {
        Single<String>
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.getLabelForEthereumAccount(
                    with: secondPassword,
                    success: { observer(.success($0)) },
                    error: { _ in observer(.error(WalletError.unknown)) }
                )
                return Disposables.create()
            }
            .subscribeOn(schedulerType)
    }
    
    private func address(secondPassword: String? = nil) -> Single<String> {
        Single<String>
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.getEthereumAddress(with: secondPassword, success: { address in
                    observer(.success(address))
                }, error: { errorMessage in
                    observer(.error(WalletError.unknown))
                })
                return Disposables.create()
            }
            .subscribeOn(schedulerType)
    }

    private func fetchHistory(fromCache: Bool) -> Single<Void> {
        let transactions: Single<[EthereumHistoricalTransaction]>
        if fromCache {
            transactions = dependencies.transactionService.transactions
        } else {
            transactions = dependencies.transactionService.fetchTransactions()
        }
        return transactions.mapToVoid()
    }
}

extension EthereumWallet: MnemonicAccessAPI {
    var mnemonic: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonic
    }
    
    var mnemonicForcePrompt: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicForcePrompt
    }
    
    var mnemonicPromptingIfNeeded: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicPromptingIfNeeded
    }
}

extension EthereumWallet: PasswordAccessAPI {
    var password: Maybe<String> {
        guard let password = credentialsProvider.legacyPassword else {
            return Maybe.empty()
        }
        return Maybe.just(password)
    }
}

extension EthereumWallet: EthereumWalletAccountBridgeAPI {
    func save(keyPair: EthereumKeyPair, label: String) -> Completable {
        guard let base58PrivateKey = keyPair.privateKey.base58EncodedString else {
            return Completable.error(WalletError.failedToSaveKeyPair("Invalid private key"))
        }
        return Completable.create(subscribe: { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.saveEthereumAccount(with: base58PrivateKey, label: label, success: {
                observer(.completed)
            }, error: { errorMessage in
                observer(.error(WalletError.failedToSaveKeyPair(errorMessage)))
            })
            return Disposables.create()
        })
    }
    
    var wallets: Single<[EthereumWalletAccount]> {
        secondPasswordIfAccountCreationNeeded
            .flatMap(weak: self) { (self, secondPassword) -> Single<[EthereumWalletAccount]> in
                self.ethereumWallets(secondPassword: secondPassword)
            }
    }
    
    private func ethereumWallets(secondPassword: String?) -> Single<[EthereumWalletAccount]> {
        Single<[[String: Any]]>
            .create(subscribe: { [weak self] observer -> Disposable in
                guard let wallet = self?.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.ethereumAccounts(with: secondPassword, success: { accounts in
                    observer(.success(accounts))
                }, error: { errorMessage in
                    observer(.error(WalletError.unknown))
                })
                return Disposables.create()
            })
            .flatMap(weak: self) { (self, legacyAccounts) -> Single<[EthereumWalletAccount]> in
                let accounts = legacyAccounts
                    .decodeJSONObjects(type: LegacyEthereumWalletAccount.self)
                    .enumerated()
                    .map { index, account -> EthereumWalletAccount in
                        EthereumWalletAccount(
                            index: index,
                            publicKey: account.addr,
                            label: account.label,
                            archived: false
                        )
                }
                return Single.just(accounts)
            }
    }

}

extension EthereumWallet: SecondPasswordPromptable {
    var legacyWallet: LegacyWalletAPI? {
        wallet
    }
    
    var accountExists: Single<Bool> {
        guard let ethereumAccountExists = ethereumAccountExists else {
            return Single.error(WalletError.notInitialized)
        }
        return Single.just(ethereumAccountExists)
    }
}
