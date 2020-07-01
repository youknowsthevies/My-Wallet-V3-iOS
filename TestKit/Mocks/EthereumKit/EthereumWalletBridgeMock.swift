//
//  EthereumWalletBridgeMock.swift
//  EthereumKitTests
//
//  Created by Jack on 28/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
@testable import EthereumKit
import PlatformKit
import RxRelay
import RxSwift

enum EthereumWalletBridgeMockError: Error {
    case mockError
}

class EthereumWalletBridgeMock: EthereumWalletBridgeAPI, EthereumWalletAccountBridgeAPI, MnemonicAccessAPI, PasswordAccessAPI {
    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        .empty()
    }

    func memo(for transactionHash: String) -> Single<String?> {
        .just(nil)
    }

    public var balanceType: BalanceType {
        .nonCustodial
    }

    var isWaitingOnTransactionValue = Single.just(false)
    var isWaitingOnTransaction: Single<Bool> {
        isWaitingOnTransactionValue
    }

    var historyValue = Single.just(())
    var history: Single<Void> {
        historyValue
    }

    func fetchHistory() -> Single<Void> {
        history
    }

    var fetchBalanceValue: Single<CryptoValue> = Single.just(CryptoValue.etherFromMajor(string: "2.0")!)
    var fetchBalance: Single<CryptoValue> {
        fetchBalanceValue
    }

    var balanceValue: Single<CryptoValue> = Single.just(CryptoValue.etherFromMajor(string: "2.0")!)
    var balance: Single<CryptoValue> {
        balanceValue
    }

    var balanceObservable: Observable<CryptoValue> {
        balance.asObservable()
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()

    var nameValue: Single<String> = Single.just("My Ether Wallet")
    var name: Single<String> {
        nameValue
    }

    var addressValue: Single<EthereumAddress> = .just(EthereumAddress(stringLiteral: MockEthereumWalletTestData.account))
    var address: Single<EthereumAddress> {
        addressValue
    }

    var transactionsValue: Single<[EthereumHistoricalTransaction]> = Single.just([])
    var transactions: Single<[EthereumHistoricalTransaction]> {
        transactionsValue
    }

    var accountValue: Single<EthereumAssetAccount> = Single.just(
        EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: "My Ether Wallet"
        )
    )
    var account: Single<EthereumAssetAccount> {
        accountValue
    }

    var nonceValue = Single.just(BigUInt(9))
    var nonce: Single<BigUInt> {
        nonceValue
    }

    var recordLastTransactionValue: Single<EthereumTransactionPublished> = Single<EthereumTransactionPublished>.error(EthereumKitError.unknown)
    var lastRecordedTransaction: EthereumTransactionPublished?
    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        lastRecordedTransaction = transaction
        return recordLastTransactionValue
    }

    // MARK: - EthereumWalletAccountBridgeAPI

    var wallets: Single<[EthereumWalletAccount]> {
        Single.just([])
    }

    func save(keyPair: EthereumKeyPair, label: String) -> Completable {
        Completable.empty()
    }

    // MARK: - MnemonicAccessAPI

    var mnemonic: Maybe<String> {
        Maybe.just("")
    }

    var mnemonicForcePrompt: Maybe<String> {
        Maybe.just("")
    }

    var mnemonicPromptingIfNeeded: Maybe<String> {
        Maybe.just("")
    }

    // MARK: - PasswordAccessAPI

    var passwordMaybe = Maybe.just("password")
    var password: Maybe<String> {
        passwordMaybe
    }
}
