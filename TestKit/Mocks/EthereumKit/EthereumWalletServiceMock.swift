//
//  EthereumWalletServiceMock.swift
//  EthereumKitTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import Foundation
import PlatformKit
import RxSwift

class EthereumWalletServiceMock: EthereumWalletServiceAPI {

    var handlePendingTransaction: Single<Void> {
        .just(())
    }

    var fetchHistoryIfNeededValue: Single<Void> = Single.just(())
    var fetchHistoryIfNeeded: Single<Void> {
        fetchHistoryIfNeededValue
    }

    var buildTransactionValue: Single<EthereumTransactionCandidate> = Single.error(NSError())
    func buildTransaction(with value: EthereumKit.EthereumValue, to: EthereumKit.EthereumAddress) -> Single<EthereumTransactionCandidate> {
        buildTransactionValue
    }

    var sendTransactionValue: Single<EthereumTransactionPublished> = Single.error(NSError())
    func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished> {
        sendTransactionValue
    }
    var transactionValidationResult: Single<TransactionValidationResult> = Single.error(NSError())
    func evaluate(amount: EthereumValue) -> Single<TransactionValidationResult> {
        transactionValidationResult
    }
}
