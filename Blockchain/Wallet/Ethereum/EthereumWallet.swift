//
//  EthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import DIKit
import ERC20Kit
import EthereumKit
import Foundation
import JavaScriptCore
import PlatformKit
import RxRelay
import RxSwift

class EthereumWallet: NSObject {

    enum EthereumWalletError: Error {
        case noEthereumAccount
        case recordLastEthereumTransactionFailed
        case getEthereumAddressFailed
        case saveERC20TokensFailed
        case erc20TokensFailed
        case getLabelForEthereumAccountFailed
        case ethereumAccountsFailed
        case encodingERC20TokenAccountsFailed
    }

    typealias Dispatcher = EthereumJSInteropDispatcherAPI & EthereumJSInteropDelegateAPI
    
    typealias WalletAPI = LegacyEthereumWalletAPI & LegacyWalletAPI & MnemonicAccessAPI
    
    var balanceObservable: Observable<CryptoValue> {
        balanceRelay.asObservable()
    }
    
    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.moneyValue
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
         walletOptionsService: WalletOptionsAPI = resolve(),
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
            .flatMap(weak: self) { (self, _) -> Observable<CryptoValue> in
                self.walletLoaded()
                    .andThen(self.balance.asObservable())
            }
            .subscribe(onNext: { [weak self] cryptoValue in
                self?.balanceRelay.accept(cryptoValue)
            })
            .disposed(by: disposeBag)
    }

    func walletLoaded() -> Completable {
        guard let wallet = wallet else {
            return .error(WalletError.notInitialized)
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
            .flatMap { .just(paxAccount) }
    }
}

extension EthereumWallet: ERC20BridgeAPI { 
    func tokenAccount(for key: String) -> Single<ERC20TokenAccount?> {
        erc20TokenAccounts.map { accounts in
            accounts[key]
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
        tokenAccount(for: tokenKey)
            .map { account in
                account?.transactionNotes[transactionHash]
            }
    }
    
    func save(transactionMemo: String, for transactionHash: String, tokenKey: String) -> Single<Void> {
        erc20TokenAccounts
            .map { tokenAccounts -> ([String: ERC20TokenAccount], ERC20TokenAccount) in
                guard let tokenAccount = tokenAccounts[tokenKey] else {
                    throw WalletError.failedToSaveMemo
                }
                return (tokenAccounts, tokenAccount)
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
        Single.create { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            guard let jsonData = try? JSONEncoder().encode(erc20TokenAccounts) else {
                observer(.error(EthereumWalletError.encodingERC20TokenAccountsFailed))
                return Disposables.create()
            }
            wallet.saveERC20Tokens(
                with: nil,
                tokensJSONString: jsonData.string,
                success: {
                    observer(.success(()))
                },
                error: { _ in
                    observer(.error(EthereumWalletError.saveERC20TokensFailed))
                }
            )
            return Disposables.create()
        }
    }
    
    private func erc20TokenAccounts(secondPassword: String? = nil) -> Single<[String: ERC20TokenAccount]> {
        Single<[String: [String: Any]]>.create { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.erc20Tokens(
                with: secondPassword,
                success: { erc20Tokens in
                    observer(.success(erc20Tokens))
                },
                error: { _ in
                    observer(.error(EthereumWalletError.erc20TokensFailed))
                }
            )
            return Disposables.create()
        }
        .map { $0.decodeJSONObjects(type: ERC20TokenAccount.self) }
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
        Single<String?>
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.getEthereumMemo(
                    for: transactionHash,
                    success: { memo in
                        observer(.success(memo))
                    },
                    error: { _ in
                        observer(.error(WalletError.notInitialized))
                    }
                )
                return Disposables.create()
            }
    }

    var accountType: SingleAccountType {
        .nonCustodial
    }
    
    var history: Single<Void> {
        fetchHistory(fromCache: false)
    }
    
    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }
    
    var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .ethereum))
    }
    
    var balanceMoney: Single<MoneyValue> {
        balance
            .moneyValue
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
            .map { wallets in
                guard let defaultAccount = wallets.first else {
                    throw EthereumWalletError.noEthereumAccount
                }
                return EthereumAssetAccount(
                    walletIndex: 0,
                    accountAddress: defaultAccount.publicKey,
                    name: defaultAccount.label ?? ""
                )
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
                    error: { _ in
                        observer(.error(EthereumWalletError.recordLastEthereumTransactionFailed))
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
                self?.legacyEthBalance = NSDecimalNumber(decimal: cryptoValue.displayMajorValue)
            })
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
                    success: { label in
                        observer(.success(label))
                    },
                    error: { _ in
                        observer(.error(EthereumWalletError.getLabelForEthereumAccountFailed))
                    }
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
                wallet.getEthereumAddress(
                    with: secondPassword,
                    success: { address in
                        observer(.success(address))
                    },
                    error: { _ in
                        observer(.error(EthereumWalletError.getEthereumAddressFailed))
                    }
                )
                return Disposables.create()
            }
            .subscribeOn(schedulerType)
    }

    private func fetchHistory(fromCache: Bool) -> Single<Void> {
        if fromCache {
            return dependencies.transactionService.transactions.mapToVoid()
        } else {
            return dependencies.transactionService.fetchTransactions().mapToVoid()
        }
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
        return Completable.create { [weak self] observer -> Disposable in
            guard let wallet = self?.wallet else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            wallet.saveEthereumAccount(
                with: base58PrivateKey,
                label: label,
                success: {
                    observer(.completed)
                },
                error: { errorMessage in
                    observer(.error(WalletError.failedToSaveKeyPair(errorMessage)))
                }
            )
            return Disposables.create()
        }
    }
    
    var wallets: Single<[EthereumWalletAccount]> {
        reactiveWallet
            .waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) -> Single<String?> in
                self.secondPasswordIfAccountCreationNeeded
            }
            .flatMap(weak: self) { (self, secondPassword) -> Single<[EthereumWalletAccount]> in
                self.ethereumWallets(secondPassword: secondPassword)
            }
    }
    
    private func ethereumWallets(secondPassword: String?) -> Single<[EthereumWalletAccount]> {
        Single<[[String: Any]]>
            .create { [weak self] observer -> Disposable in
                guard let wallet = self?.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.ethereumAccounts(
                    with: secondPassword,
                    success: { account in
                        observer(.success(account))
                    },
                    error: { _ in
                        observer(.error(EthereumWalletError.ethereumAccountsFailed))
                    }
                )
                return Disposables.create()
            }
            .map { $0.decodeJSONObjects(type: LegacyEthereumWalletAccount.self) }
            .map { legacyWallets in
                legacyWallets.enumerated()
                    .map { offset, account in
                        EthereumWalletAccount(
                            index: offset,
                            publicKey: account.addr,
                            label: account.label,
                            archived: false
                        )
                    }
            }
    }
}

extension EthereumWallet: SecondPasswordPromptable {
    var legacyWallet: LegacyWalletAPI? {
        wallet
    }
    
    var accountExists: Single<Bool> {
        guard let ethereumAccountExists = ethereumAccountExists else {
            return .error(WalletError.notInitialized)
        }
        return .just(ethereumAccountExists)
    }
}
