//
//  EthereumTransactionCandidateBuilder.swift
//  EthereumKit
//
//  Created by Jack on 17/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit
import RxSwift
import web3swift

public protocol EthereumTransactionBuildingServiceAPI {
    func buildTransaction(with amount: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate>
}

public class EthereumTransactionBuildingService: EthereumTransactionBuildingServiceAPI {
    private let feeService: EthereumFeeServiceAPI
    private let repository: EthereumAssetAccountRepository
    
    public init(with feeService: EthereumFeeServiceAPI,
                repository: EthereumAssetAccountRepository) {
        self.feeService = feeService
        self.repository = repository
    }
    
    public func buildTransaction(with amount: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate> {
        Single.zip(feeService.fees, balance)
            .flatMap { tuple -> Single<EthereumTransactionCandidate> in
                let (fee, balanceSigned) = tuple
                let value: BigUInt = BigUInt(amount.amount)
                let gasPrice = BigUInt(fee.regular.amount)
                let gasLimit = BigUInt(fee.gasLimit)
                let balance = BigUInt(balanceSigned.amount)
                let transactionFee = gasPrice * gasLimit
                
                guard transactionFee < balance else {
                    throw EthereumKitValidationError.insufficientFunds
                }
                
                let availableBalance = balance - transactionFee
                
                guard value <= availableBalance else {
                    throw EthereumKitValidationError.insufficientFunds
                }
                
                let transaction = EthereumTransactionCandidate(
                    to: to,
                    gasPrice: BigUInt(fee.regular.amount),
                    gasLimit: BigUInt(fee.gasLimit),
                    value: value,
                    data: Data()
                )
                return Single.just(transaction)
        }
    }
    
    private var balance: Single<CryptoValue> {
        repository.currentAssetAccountDetails(fromCache: false).flatMap(weak: self, { (self, details) -> Single<CryptoValue> in
            Single.just(details.balance)
        })
    }
}
