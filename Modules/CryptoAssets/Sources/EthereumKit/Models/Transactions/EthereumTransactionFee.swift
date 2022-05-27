// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public struct EthereumTransactionFee {

    // MARK: Types

    public enum FeeLevel {
        case regular
        case priority
    }

    // MARK: Static Methods

    static func `default`(network: EVMNetwork) -> EthereumTransactionFee {
        switch network {
        case .ethereum:
            return EthereumTransactionFee(
                regular: 50,
                priority: 100,
                gasLimit: 21000,
                gasLimitContract: 75000,
                network: .ethereum
            )
        case .polygon:
            return EthereumTransactionFee(
                regular: 30,
                priority: 40,
                gasLimit: 21000,
                gasLimitContract: 75000,
                network: .polygon
            )
        }
    }

    // MARK: Private Properties

    private let regular: CryptoValue
    private let priority: CryptoValue
    private let gasLimit: Int
    private let gasLimitContract: Int
    private let network: EVMNetwork

    // MARK: Init

    init(
        regular: Int,
        priority: Int,
        gasLimit: Int,
        gasLimitContract: Int,
        network: EVMNetwork
    ) {
        self.regular = .ether(gwei: BigInt(regular), network: network)
        self.priority = .ether(gwei: BigInt(priority), network: network)
        self.gasLimit = gasLimit
        self.gasLimitContract = gasLimitContract
        self.network = network
    }

    // MARK: Private Methods

    public func gasPrice(feeLevel: FeeLevel) -> BigUInt {
        switch feeLevel {
        case .regular:
            return BigUInt(regular.amount)
        case .priority:
            return BigUInt(priority.amount)
        }
    }

    public func gasLimit(
        extraGasLimit: BigUInt = 0,
        isContract: Bool
    ) -> BigUInt {
        BigUInt(isContract ? gasLimitContract : gasLimit)
            + extraGasLimit
    }

    public func absoluteFee(
        with feeLevel: FeeLevel,
        extraGasLimit: BigUInt = 0,
        isContract: Bool
    ) -> CryptoValue {
        let price = gasPrice(feeLevel: feeLevel)
        let gasLimit = gasLimit(extraGasLimit: extraGasLimit, isContract: isContract)
        let amount = price * gasLimit
        return CryptoValue
            .create(
                minor: BigInt(amount),
                currency: network.cryptoCurrency
            )
    }
}

extension CryptoValue {

    static func ether(
        gwei: BigInt,
        network: EVMNetwork
    ) -> CryptoValue {
        let wei = gwei * BigInt(1e9)
        return CryptoValue(
            amount: wei,
            currency: network.cryptoCurrency
        )
    }
}
