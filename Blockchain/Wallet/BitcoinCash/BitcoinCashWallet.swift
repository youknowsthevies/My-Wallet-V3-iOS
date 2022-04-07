// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import WalletPayloadKit

final class BitcoinCashWallet: BitcoinCashWalletBridgeAPI {

    // MARK: - BitcoinCashWalletBridgeAPI

    var defaultWallet: Single<BitcoinCashWalletAccount> {
        reactiveWallet
            .waitUntilInitializedFirst
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap(weak: self) { (self, _) -> Single<BitcoinCashWalletAccount> in
                self.fetchDefaultWallet()
            }
    }

    var wallets: Single<[BitcoinCashWalletAccount]> {
        reactiveWallet
            .waitUntilInitializedFirst
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap(weak: self) { (self, _) -> Single<[BitcoinCashWalletAccount]> in
                self.fetchAllWallets()
            }
    }

    // MARK: - Injected

    private let reactiveWallet: ReactiveWalletAPI
    private let wallet: LegacyBitcoinCashWalletProtocol

    init(
        reactiveWallet: ReactiveWalletAPI = resolve(),
        walletManager: WalletManager = resolve()
    ) {
        self.reactiveWallet = reactiveWallet
        wallet = walletManager.wallet
    }

    func receiveAddress(forXPub xpub: String) -> Single<String> {
        reactiveWallet
            .waitUntilInitialized
            .asObservable()
            .take(1)
            .asSingle()
            .map(weak: self) { (self, _) -> String in
                let result = self.wallet.getBitcoinCashReceiveAddress(forXPub: xpub)
                switch result {
                case .success(let address):
                    return address
                case .failure(let error):
                    fatalError(String(describing: error))
                }
            }
            .map { $0.replacingOccurrences(of: "bitcoincash:", with: "") }
    }

    func firstReceiveAddress(forXPub xpub: String) -> Single<String> {
        reactiveWallet
            .waitUntilInitialized
            .asSingle()
            .map(weak: self) { (self, _) -> String in
                let result = self.wallet.getBitcoinCashFirstReceiveAddress(forXPub: xpub)
                switch result {
                case .success(let address):
                    return address
                case .failure(let error):
                    fatalError(String(describing: error))
                }
            }
            .map { $0.replacingOccurrences(of: "bitcoincash:", with: "") }
    }

    func note(for transactionHash: String) -> Single<String?> {
        Single<String?>
            .create(weak: self) { (self, observer) -> Disposable in
                self.wallet.getBitcoinCashNote(
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
            self.wallet.setBitcoinCashNote(for: transactionHash, note: note)
            completable(.completed)
            return Disposables.create()
        }
        return reactiveWallet
            .waitUntilInitialized
            .asObservable()
            .flatMap { setNote.asObservable() }
            .asCompletable()
    }

    func update(accountIndex: Int, label: String) -> Completable {
        reactiveWallet
            .waitUntilInitializedFirst
            .asObservable()
            .take(1)
            .asSingle()
            .flatMapCompletable(weak: self) { (self, _) -> Completable in
                self.wallet.updateAccountLabel(.bitcoinCash, index: accountIndex, label: label)
            }
    }

    // MARK: - Private

    private func fetchAllWallets() -> Single<[BitcoinCashWalletAccount]> {
        Single<[BitcoinCashWalletAccount]>.create(weak: self) { (self, observer) -> Disposable in
            guard let payload: [[String: Any]] = self.wallet.bitcoinCashWallets() else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }
            let accounts: [BitcoinCashWalletAccount] = payload.compactMap { data in
                guard
                    let label = data["label"] as? String,
                    let index = data["index"] as? NSNumber,
                    let xpub = data["xpub"] as? String,
                    let archived = data["archived"] as? Bool
                else {
                    return nil
                }

                return BitcoinCashWalletAccount(
                    index: index.intValue,
                    publicKey: xpub,
                    label: label,
                    derivationType: .legacy,
                    archived: archived
                )
            }
            observer(.success(accounts))
            return Disposables.create()
        }
    }

    private func fetchDefaultWallet() -> Single<BitcoinCashWalletAccount> {
        Single<BitcoinCashWalletAccount>.create(weak: self) { (self, observer) -> Disposable in
            guard let payload = self.wallet.bitcoinCashDefaultWallet() else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }
            guard
                let label = payload["label"] as? String,
                let index = payload["index"] as? NSNumber,
                let xpub = payload["xpub"] as? String,
                let archived = payload["archived"] as? Bool
            else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }

            let account = BitcoinCashWalletAccount(
                index: index.intValue,
                publicKey: xpub,
                label: label,
                derivationType: .legacy,
                archived: archived
            )
            observer(.success(account))
            return Disposables.create()
        }
    }
}
