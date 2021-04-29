// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxSwift

final class EthereumTransactionValidationService: ValidateTransactionAPI {
    
    private let feeService: AnyCryptoFeeService<EthereumTransactionFee>
    private let repository: EthereumAssetAccountRepository
    
    init(with feeService: AnyCryptoFeeService<EthereumTransactionFee> = resolve(),
         repository: EthereumAssetAccountRepository = resolve()) {
        self.feeService = feeService
        self.repository = repository
    }
    
    func validateCryptoAmount(amount: CryptoMoney) -> Single<TransactionValidationResult> {
        Single.zip(feeService.fees, balance)
            .flatMap { tuple -> Single<TransactionValidationResult> in
                let (fee, balanceSigned) = tuple
                let value: BigUInt = BigUInt(amount.amount)
                let gasPrice = BigUInt(fee.regular.amount)
                let gasLimit = BigUInt(fee.gasLimit)
                let balance = BigUInt(balanceSigned.amount)
                let transactionFee = gasPrice * gasLimit
                
                guard transactionFee < balance else {
                    return Single.just(.invalid(EthereumKitValidationError.insufficientFeeCoverage))
                }
                
                let availableBalance = balance - transactionFee
                
                guard value <= availableBalance else {
                    return Single.just(.invalid(EthereumKitValidationError.insufficientFunds))
                }
                
                return Single.just(.ok)
        }
    }
    
    private var balance: Single<CryptoValue> {
        repository.currentAssetAccountDetails(fromCache: false).flatMap(weak: self, { (self, details) -> Single<CryptoValue> in
            Single.just(details.balance)
        })
    }
}

