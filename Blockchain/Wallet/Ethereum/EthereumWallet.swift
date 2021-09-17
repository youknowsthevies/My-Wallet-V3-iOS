// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import ERC20Kit
import EthereumKit
import Foundation
import JavaScriptCore
import PlatformKit
import RxRelay
import RxSwift

final class EthereumWallet: NSObject {

    // MARK: Types

    typealias Dispatcher = EthereumJSInteropDispatcherAPI & EthereumJSInteropDelegateAPI

    typealias WalletAPI = LegacyEthereumWalletAPI & LegacyWalletAPI & MnemonicAccessAPI

    enum EthereumWalletError: Error {
        case noEthereumAccount
        case recordLastEthereumTransactionFailed
        case getEthereumAddressFailed
        case saveERC20TokensFailed
        case erc20TokensFailed
        case getLabelForEthereumAccountFailed
        case ethereumAccountsFailed
    }

    // MARK: Properties

    weak var reactiveWallet: ReactiveWalletAPI!
    var delegate: EthereumJSInteropDelegateAPI {
        dispatcher
    }

    @available(*, deprecated, message: "making this so tests will compile")
    var interopDispatcher: EthereumJSInteropDispatcherAPI {
        dispatcher
    }

    // MARK: Private Properties

    private lazy var credentialsProvider: WalletCredentialsProviding = WalletManager.shared.legacyRepository
    private weak var wallet: WalletAPI?
    private let secondPasswordPrompter: SecondPasswordPromptable
    private let schedulerType: SchedulerType
    private let dispatcher: Dispatcher

    // MARK: Initializer

    @objc convenience init(legacyWallet: Wallet) {
        self.init(schedulerType: MainScheduler.instance, wallet: legacyWallet)
    }

    init(
        schedulerType: SchedulerType = MainScheduler.instance,
        secondPasswordPrompter: SecondPasswordPromptable = resolve(),
        wallet: WalletAPI,
        dispatcher: Dispatcher = EthereumJSInteropDispatcher.shared
    ) {
        self.schedulerType = schedulerType
        self.secondPasswordPrompter = secondPasswordPrompter
        self.wallet = wallet
        self.dispatcher = dispatcher
        super.init()
    }

    @objc func setup(with context: JSContext) {
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
        let saveMemo = Completable.create { completable in
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

    var name: Single<String> {
        secondPasswordPrompter.secondPasswordIfNeeded(type: .actionRequiresPassword)
            .asSingle()
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                self.label(secondPassword: secondPassword)
            }
    }

    var address: Single<EthereumAddress> {
        reactiveWallet.waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) in
                self.secondPasswordPrompter.secondPasswordIfNeeded(type: .actionRequiresPassword)
                    .asSingle()
            }
            .flatMap(weak: self) { (self, secondPassword) -> Single<String> in
                self.address(secondPassword: secondPassword)
            }
            .map { try EthereumAddress(string: $0) }
    }

    var account: Single<EthereumAssetAccount> {
        wallets
            .asSingle()
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
    var wallets: AnyPublisher<[EthereumWalletAccount], Error> {
        reactiveWallet
            .waitUntilInitializedSinglePublisher
            .setFailureType(to: SecondPasswordError.self)
            .flatMap { [secondPasswordPrompter] _ in
                secondPasswordPrompter.secondPasswordIfNeeded(type: .actionRequiresPassword)
            }
            .eraseError()
            .flatMap { [weak self] secondPassword -> AnyPublisher<[EthereumWalletAccount], Error> in
                guard let self = self else {
                    return .failure(WalletError.notInitialized)
                }
                return self.ethereumWallets(secondPassword: secondPassword)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    private func ethereumWallets(
        secondPassword: String?
    ) -> AnyPublisher<[EthereumWalletAccount], Error> {
        AnyPublisher<[[String: Any]], Error>
            .create { [weak self] subscriber in
                guard let wallet = self?.wallet else {
                    subscriber.send(completion: .failure(WalletError.notInitialized))
                    return AnyCancellable {}
                }
                wallet.ethereumAccounts(
                    with: secondPassword,
                    success: { accounts in
                        subscriber.send(accounts)
                        subscriber.send(completion: .finished)
                    },
                    error: { _ in
                        subscriber.send(completion: .failure(EthereumWalletError.ethereumAccountsFailed))
                    }
                )
                return AnyCancellable {}
            }
            .map { accounts in
                accounts.decodeJSONObjects(type: LegacyEthereumWalletAccount.self)
            }
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
            .eraseError()
            .eraseToAnyPublisher()
    }
}
