// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxSwift
import TransactionKit

protocol EthereumTransactionBuildingServiceAPI {
    
    func buildTransaction(with amount: EthereumValue,
                          to: EthereumAddress,
                          feeLevel: FeeLevel) -> Single<EthereumTransactionCandidate>
}

final class EthereumTransactionBuildingService: EthereumTransactionBuildingServiceAPI {
    
    private let feeService: AnyCryptoFeeService<EthereumTransactionFee>
    private let repository: EthereumAssetAccountRepository
    
    init(with feeService: AnyCryptoFeeService<EthereumTransactionFee> = resolve(),
         repository: EthereumAssetAccountRepository = resolve()) {
        self.feeService = feeService
        self.repository = repository
    }

    private func fee(feeLevel: FeeLevel) -> Single<(gasLimit: Int, gasPrice: CryptoValue)> {
        feeService.fees.map { fee in
            switch feeLevel {
            case .priority:
                return (fee.gasLimit, fee.priority)
            case .custom, .none, .regular:
                return (fee.gasLimit, fee.regular)
            }
        }
    }

    func buildTransaction(with amount: EthereumValue,
                          to: EthereumAddress,
                          feeLevel: FeeLevel) -> Single<EthereumTransactionCandidate> {
        Single
            .zip(fee(feeLevel: feeLevel), balance)
            .map { (fee, balance) -> EthereumTransactionCandidate in
                let value: BigUInt = BigUInt(amount.amount)
                let gasPrice = BigUInt(fee.gasPrice.amount)
                let gasLimit = BigUInt(fee.gasLimit)
                let balance = BigUInt(balance.amount)
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
                    gasPrice: gasPrice,
                    gasLimit: gasLimit,
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
