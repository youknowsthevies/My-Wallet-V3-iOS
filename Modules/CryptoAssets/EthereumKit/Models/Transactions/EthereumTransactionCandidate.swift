//
//  EthereumTransactionCandidate.swift
//  EthereumKit
//
//  Created by Jack on 26/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

public struct EthereumTransactionCandidate: Equatable {
    public enum TransferType: Equatable {
        case transfer
        case erc20Transfer(contract: EthereumAddress)
    }
    public let to: EthereumAddress
    public let gasPrice: BigUInt
    public let gasLimit: BigUInt
    public let value: BigUInt
    public let data: Data?
    public let transferType: TransferType
    
    public init(to: EthereumAddress,
                gasPrice: BigUInt,
                gasLimit: BigUInt,
                value: BigUInt,
                data: Data?,
                transferType: TransferType = .transfer) {
        self.to = to
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
        self.data = data
        self.transferType = transferType
    }
}
