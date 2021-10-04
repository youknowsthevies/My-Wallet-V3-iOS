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

    typealias EthereumDispatcher = EthereumJSInteropDispatcherAPI & EthereumJSInteropDelegateAPI

    typealias WalletAPI = LegacyEthereumWalletAPI & LegacyWalletAPI & MnemonicAccessAPI

    enum EthereumWalletError: Error {
        case recordLastEthereumTransactionFailed
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

    private weak var wallet: WalletAPI?
    private let secondPasswordPrompter: SecondPasswordPromptable
    private let dispatcher: EthereumDispatcher

    // MARK: Initializer

    @objc convenience init(legacyWallet: Wallet) {
        self.init(wallet: legacyWallet)
    }

    init(
        secondPasswordPrompter: SecondPasswordPromptable = resolve(),
        wallet: WalletAPI,
        dispatcher: EthereumDispatcher = EthereumJSInteropDispatcher.shared
    ) {
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

    func note(for transactionHash: String) -> Single<String?> {
        Single<String?>
            .create(weak: self) { (self, observer) -> Disposable in
                guard let wallet = self.wallet else {
                    observer(.error(WalletError.notInitialized))
                    return Disposables.create()
                }
                wallet.getEthereumNote(
                    for: transactionHash,
                    success: { note in
                        observer(.success(note))
                    },
                    error: { _ in
                        observer(.error(WalletError.notInitialized))
                    }
                )
                return Disposables.create()
            }
    }

    func updateNote(for transactionHash: String, note: String?) -> Completable {
        let setNote = Completable.create { completable in
            self.wallet?.setEthereumNote(for: transactionHash, note: note)
            completable(.completed)
            return Disposables.create()
        }
        return reactiveWallet
            .waitUntilInitialized
            .flatMap { setNote.asObservable() }
            .asCompletable()
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
