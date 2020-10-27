//
//  EthereumTransactionCandidateBuilder.swift
//  EthereumKit
//
//  Created by Jack on 17/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import DIKit
import PlatformKit
import RxSwift
import web3swift

protocol EthereumTransactionBuildingServiceAPI {
    
    func buildTransaction(with amount: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate>
}

final class EthereumTransactionBuildingService: EthereumTransactionBuildingServiceAPI {
    
    private let feeService: AnyCryptoFeeService<EthereumTransactionFee>
    private let repository: EthereumAssetAccountRepository
    
    init(with feeService: AnyCryptoFeeService<EthereumTransactionFee> = resolve(),
         repository: EthereumAssetAccountRepository = resolve()) {
        self.feeService = feeService
        self.repository = repository
    }
    
    func buildTransaction(with amount: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate> {
        Single.zip(feeService.fees, balance) { (fees: $0, balance: $1) }
            .map { data -> EthereumTransactionCandidate in
                let value: BigUInt = BigUInt(amount.amount)
                let gasPrice = BigUInt(data.fees.regular.amount)
                let gasLimit = BigUInt(data.fees.gasLimit)
                let balance = BigUInt(data.balance.amount)
                let transactionFee = gasPrice * gasLimit
                
                guard transactionFee < balance else {
                    throw EthereumKitValidationError.insufficientFunds
                }
                
                let availableBalance = balance - transactionFee
                
                guard value <= availableBalance else {
                    throw EthereumKitValidationError.insufficientFunds
                }
                
                return EthereumTransactionCandidate(
                    to: to,
                    gasPrice: BigUInt(data.fees.regular.amount),
                    gasLimit: BigUInt(data.fees.gasLimit),
                    value: value,
                    data: Data()
                )
            }
    }
    
    private var balance: Single<CryptoValue> {
        repository.currentAssetAccountDetails(fromCache: false).flatMap(weak: self, { (self, details) -> Single<CryptoValue> in
            Single.just(details.balance)
        })
    }
}
