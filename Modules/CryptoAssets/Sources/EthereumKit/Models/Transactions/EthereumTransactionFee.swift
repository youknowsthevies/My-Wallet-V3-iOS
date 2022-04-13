// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public struct EthereumTransactionFee {

    public enum FeeLevel {
        case regular
        case priority
    }

    static let `default` = EthereumTransactionFee(
        regular: 90,
        priority: 110,
        gasLimit: 21000,
        gasLimitContract: 75000
    )

    private let regular: CryptoValue
    private let priority: CryptoValue
    private let gasLimit: Int
    private let gasLimitContract: Int

    init(regular: Int, priority: Int, gasLimit: Int, gasLimitContract: Int) {
        self.regular = CryptoValue.ether(gwei: BigInt(regular))
        self.priority = CryptoValue.ether(gwei: BigInt(priority))
        self.gasLimit = gasLimit
        self.gasLimitContract = gasLimitContract
    }

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
        return CryptoValue.create(minor: BigInt(amount), currency: .ethereum)
    }
}

extension CryptoValue {

    static func ether(gwei: BigInt) -> CryptoValue {
        let wei = gwei * BigInt(1e9)
        return CryptoValue(amount: wei, currency: .ethereum)
    }
}
