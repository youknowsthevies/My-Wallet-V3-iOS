// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
    }

    typealias Dispatcher = EthereumJSInteropDispatcherAPI & EthereumJSInteropDelegateAPI

    typealias WalletAPI = LegacyEthereumWalletAPI & LegacyWalletAPI & MnemonicAccessAPI

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
    private let secondPasswordPrompter: SecondPasswordPromptable

    /// These are lazy because we have a dependency cycle, and injecting using `EthereumWallet` initializer
    /// overflows the function stack with initializers that call one another
    @LazyInject private var historicalTransactionService: EthereumHistoricalTransactionService

    /// NOTE: This is to fix flaky tests - interaction with `Wallet` should be performed on the main scheduler
    private let schedulerType: SchedulerType
    private let dispatcher: Dispatcher

    @objc convenience init(legacyWallet: Wallet) {
        self.init(schedulerType: MainScheduler.instance, wallet: legacyWallet)
    }

    convenience init(schedulerType: SchedulerType, legacyWallet: Wallet) {
        self.init(schedulerType: schedulerType, wallet: legacyWallet)
    }

    init(schedulerType: SchedulerType = MainScheduler.instance,
         walletOptionsService: WalletOptionsAPI = resolve(),
         secondPasswordPrompter: SecondPasswordPromptable = resolve(),
         wallet: WalletAPI,
         dispatcher: Dispatcher = EthereumJSInteropDispatcher.shared) {
        self.schedulerType = schedulerType
        self.walletOptionsService = walletOptionsService
        self.secondPasswordPrompter = secondPasswordPrompter
        self.wallet = wallet
        self.dispatcher = dispatcher
        super.init()
    }

    @objc func setup(with context: JSContext) {
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
}

extension EthereumWallet: EthereumWalletBridgeAPI {

    func update(accountIndex: Int, label: String) -> Completable {
        reactiveWallet
            .waitUntilInitializedSingle
            .flatMapCompletable(weak: self) { (self, _) -> Completable in
                guard let wallet = self.wallet else {
                    return .error(WalletError.notInitialized)
                }
                return wallet.updateAccountLabel(.ethereum, index: accountIndex, label: label)
            }
    }

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

    var history: Single<Void> {
        fetchHistory(fromCache: false)
    }

    var name: Single<String> {
        secondPasswordPrompter.secondPasswordIfNeeded(type: .actionRequiresPassword)
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                self.label(secondPassword: secondPassword)
            }
    }

    var address: Single<EthereumAddress> {
        reactiveWallet.waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) in
                self.secondPasswordPrompter.secondPasswordIfNeeded(type: .actionRequiresPassword)
            }
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                self.address(secondPassword: secondPassword)
            }
            .map { EthereumAddress(stringLiteral: $0) }
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

    /// Streams `true` if there is a prending transaction
    var isWaitingOnTransaction: Single<Bool> {
        historicalTransactionService
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
            return historicalTransactionService.transactions.mapToVoid()
        } else {
            return historicalTransactionService.fetchTransactions().mapToVoid()
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

    var mnemonicPromptingIfNeeded: Maybe<String> {
        guard let wallet = wallet else {
            return Maybe.empty()
        }
        return wallet.mnemonicPromptingIfNeeded
    }

    func mnemonic(with secondPassword: String?) -> Single<Mnemonic> {
        guard let wallet = wallet else {
            return .error(PlatformKitError.default)
        }
        return wallet.mnemonic(with: secondPassword)
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
    var wallets: Single<[EthereumWalletAccount]> {
        reactiveWallet
            .waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) -> Single<String?> in
                self.secondPasswordPrompter.secondPasswordIfNeeded(type: .actionRequiresPassword)
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
