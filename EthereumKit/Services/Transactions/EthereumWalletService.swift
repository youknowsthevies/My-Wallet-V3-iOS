//
//  EthereumWalletService.swift
//  EthereumKit
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BigInt
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

public final class EthereumWalletService: EthereumWalletServiceAPI {
    public typealias Bridge = EthereumWalletBridgeAPI
    
    public var fetchHistoryIfNeeded: Single<Void> {
        bridge.history
    }

    public var handlePendingTransaction: Single<Void> {
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
    
    private let bridge: Bridge
    private let client: APIClientAPI
    private let feeService: EthereumFeeServiceAPI
    private let walletAccountRepository: EthereumWalletAccountRepositoryAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI
    private let transactionSendingService: EthereumTransactionSendingServiceAPI
    private let transactionValidationService: ValidateTransactionAPI

    public convenience init(with bridge: Bridge,
                            feeService: EthereumFeeServiceAPI,
                            walletAccountRepository: EthereumWalletAccountRepositoryAPI,
                            transactionBuildingService: EthereumTransactionBuildingServiceAPI,
                            transactionSendingService: EthereumTransactionSendingServiceAPI,
                            transactionValidationService: ValidateTransactionAPI) {
        self.init(with: bridge,
                  client: resolve(),
                  feeService: feeService,
                  walletAccountRepository: walletAccountRepository,
                  transactionBuildingService: transactionBuildingService,
                  transactionSendingService: transactionSendingService,
                  transactionValidationService: transactionValidationService)
    }

    public init(with bridge: Bridge,
                client: APIClientAPI,
                feeService: EthereumFeeServiceAPI,
                walletAccountRepository: EthereumWalletAccountRepositoryAPI,
                transactionBuildingService: EthereumTransactionBuildingServiceAPI,
                transactionSendingService: EthereumTransactionSendingServiceAPI,
                transactionValidationService: ValidateTransactionAPI) {
        self.bridge = bridge
        self.client = client
        self.feeService = feeService
        self.walletAccountRepository = walletAccountRepository
        self.transactionBuildingService = transactionBuildingService
        self.transactionSendingService = transactionSendingService
        self.transactionValidationService = transactionValidationService
    }
    
    public func evaluate(amount: EthereumValue) -> Single<TransactionValidationResult> {
        handlePendingTransactionResult.flatMap(weak: self) { (self, result) -> Single<TransactionValidationResult> in
            guard result.isOk else { return .just(result) }
            return self.transactionValidationService.validateCryptoAmount(amount: amount)
        }
    }
    
    public func buildTransaction(with value: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate> {
        handlePendingTransactionResult.flatMap(weak: self) { (self, result) -> Single<EthereumTransactionCandidate> in
            // Throw error if received from earlier step
            if let error = result.error { throw error }
            return self.transactionBuildingService.buildTransaction(with: value, to: to)
        }
    }
    
    public func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished> {
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
