//
//  EthereumTransactionBuilder.swift
//  EthereumKit
//
//  Created by Jack on 26/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit
import RxSwift
import web3swift

protocol EthereumTransactionBuilderAPI {
    
    func build(transaction: EthereumTransactionCandidate) -> Result<EthereumTransactionCandidateCosted, EthereumKitValidationError>
}

final class EthereumTransactionBuilder: EthereumTransactionBuilderAPI {
    
    func build(transaction: EthereumTransactionCandidate
        ) -> Result<EthereumTransactionCandidateCosted, EthereumKitValidationError> {
        
        let value = transaction.value
        let gasPrice = transaction.gasPrice
        let gasLimit = transaction.gasLimit
        let data = transaction.data ?? Data()
        
        let to: web3swift.Address = transaction.to.web3swiftAddress
        
        var tx: web3swift.EthereumTransaction = web3swift.EthereumTransaction(
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: to,
            value: value,
            data: data
        )
        tx.UNSAFE_setChainID(NetworkId.mainnet)
        
        // swiftlint:disable:next force_try
        return .success(try! EthereumTransactionCandidateCosted(transaction: tx))
    }
}
