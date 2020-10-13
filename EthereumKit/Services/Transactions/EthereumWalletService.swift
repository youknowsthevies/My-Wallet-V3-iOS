//
//  EthereumWalletService.swift
//  EthereumKit
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import DIKit
import PlatformKit
import RxSwift

public enum EthereumKitValidationError: TransactionValidationError {
    case waitingOnPendingTransaction
    case insufficientFeeCoverage
    case insufficientFunds
    case invalidAmount
}

public enum EthereumWalletServiceError: Error {
    case unknown
}

public protocol EthereumWalletServiceAPI {
    
    var handlePendingTransaction: Single<Void> { get }
    var fetchHistoryIfNeeded: Single<Void> { get }
    
    func evaluate(amount: EthereumValue) -> Single<TransactionValidationResult>
    func buildTransaction(with value: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate>
    func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished>
}

final class EthereumWalletService: EthereumWalletServiceAPI {
    
    var fetchHistoryIfNeeded: Single<Void> {
        bridge.history
    }

    var handlePendingTransaction: Single<Void> {
        bridge.isWaitingOnTransaction
            .flatMap { isWaiting -> Single<Void> in
                guard !isWaiting else {
                    throw EthereumKitValidationError.waitingOnPendingTransaction
                }
                return Single.just(())
            }
    }
    
    private var handlePendingTransactionResult: Single<TransactionValidationResult> {
        handlePendingTransaction
            .map { _ in .ok }
            .catchError { error -> Single<TransactionValidationResult> in
                switch error {
                case EthereumKitValidationError.waitingOnPendingTransaction:
                    return .just(TransactionValidationResult.invalid(EthereumKitValidationError.waitingOnPendingTransaction))
                default:
                    throw error
                }
            }
    }
    
    private var loadKeyPair: Single<EthereumKeyPair> {
        walletAccountRepository.keyPair.asObservable().asSingle()
    }
    
    private let bridge: EthereumWalletBridgeAPI
    private let client: APIClientAPI
    private let feeService: AnyCryptoFeeService<EthereumTransactionFee>
    private let walletAccountRepository: EthereumWalletAccountRepositoryAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI
    private let transactionSendingService: EthereumTransactionSendingServiceAPI
    private let transactionValidationService: EthereumTransactionValidationService

    init(with bridge: EthereumWalletBridgeAPI = resolve(),
         client: APIClientAPI = resolve(),
         feeService: AnyCryptoFeeService<EthereumTransactionFee> = resolve(),
         walletAccountRepository: EthereumWalletAccountRepositoryAPI = resolve(),
         transactionBuildingService: EthereumTransactionBuildingServiceAPI = resolve(),
         transactionSendingService: EthereumTransactionSendingServiceAPI = resolve(),
         transactionValidationService: EthereumTransactionValidationService = resolve()) {
        self.bridge = bridge
        self.client = client
        self.feeService = feeService
        self.walletAccountRepository = walletAccountRepository
        self.transactionBuildingService = transactionBuildingService
        self.transactionSendingService = transactionSendingService
        self.transactionValidationService = transactionValidationService
    }
    
    func evaluate(amount: EthereumValue) -> Single<TransactionValidationResult> {
        handlePendingTransactionResult.flatMap(weak: self) { (self, result) -> Single<TransactionValidationResult> in
            guard result.isOk else { return .just(result) }
            return self.transactionValidationService.validateCryptoAmount(amount: amount)
        }
    }
    
    func buildTransaction(with value: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate> {
        handlePendingTransactionResult.flatMap(weak: self) { (self, result) -> Single<EthereumTransactionCandidate> in
            // Throw error if received from earlier step
            if let error = result.error { throw error }
            return self.transactionBuildingService.buildTransaction(with: value, to: to)
        }
    }
    
    func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished> {
        handlePendingTransaction
            .flatMap(weak: self) { (self, _) -> Single<EthereumKeyPair> in
                self.loadKeyPair
            }
            .flatMap(weak: self) { (self, keyPair) -> Single<EthereumTransactionPublished> in
                self.prepareAndPush(transaction: transaction, keyPair: keyPair)
            }
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                self.updateAfterSending(transaction: transaction)
            }
    }
    
    private func prepareAndPush(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionPublished> {
        transactionSendingService.send(
            transaction: transaction,
            keyPair: keyPair
        )
    }
    
    private func updateAfterSending(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        bridge.recordLast(transaction: transaction)
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                self.bridge.fetchHistory().map { _ -> EthereumTransactionPublished in
                    transaction
                }
            }
    }
}
