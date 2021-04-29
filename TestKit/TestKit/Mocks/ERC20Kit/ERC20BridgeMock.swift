// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import ERC20Kit
import EthereumKit
import Foundation
import PlatformKit
import RxSwift

class ERC20BridgeMock: ERC20BridgeAPI {
    
    var isWaitingOnTransactionValue: Single<Bool> = Single.just(false)
    var isWaitingOnTransaction: Single<Bool> {
        isWaitingOnTransactionValue
    }
    
    func tokenAccount(for key: String) -> Single<ERC20TokenAccount?> {
        Single.just(nil)
    }
    
    var erc20TokenAccountsValue: Single<[String: ERC20TokenAccount]> = Single.just([:])
    var erc20TokenAccounts: Single<[String: ERC20TokenAccount]> {
        erc20TokenAccountsValue
    }
    
    var saveERC20TokenAccountsValue: Single<Void> = Single.just(())
    func save(erc20TokenAccounts: [String: ERC20TokenAccount]) -> Single<Void> {
        saveERC20TokenAccountsValue
    }
    
    var lastTransactionHashFetched: String?
    var lastTokenKeyFetched: String?
    var memoForTransactionHashValue: Single<String?> = Single.just("memo")
    func memo(for transactionHash: String, tokenKey: String) -> Single<String?> {
        lastTransactionHashFetched = transactionHash
        lastTokenKeyFetched = tokenKey
        return memoForTransactionHashValue
    }
    
    var lastTransactionMemoSaved: String?
    var lastTransactionHashSaved: String?
    var lastTokenKeySaved: String?
    var saveTransactionMemoForTransactionHashValue: Single<Void> = Single.just(())
    func save(transactionMemo: String, for transactionHash: String, tokenKey: String) -> Single<Void> {
        lastTransactionMemoSaved = transactionMemo
        lastTransactionHashSaved = transactionHash
        lastTokenKeySaved = tokenKey
        return saveTransactionMemoForTransactionHashValue
    }
}
