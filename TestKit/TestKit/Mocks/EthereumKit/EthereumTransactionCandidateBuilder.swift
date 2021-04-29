// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import EthereumKit

class EthereumTransactionCandidateBuilder {
    var to: EthereumAddress? = EthereumAddress(stringLiteral: "0x3535353535353535353535353535353535353535")
    var value: BigUInt? = MockEthereumWalletTestData.Transaction.value
    var gasPrice: BigUInt? = MockEthereumWalletTestData.Transaction.gasPrice
    var gasLimit: BigUInt? = MockEthereumWalletTestData.Transaction.gasLimit
    var data: Data?

    func with(toAccountAddress: String) -> Self {
        self.to = EthereumAddress(stringLiteral: toAccountAddress)
        return self
    }

    func with(value: BigUInt) -> Self {
        self.value = value
        return self
    }

    func with(gasPrice: BigUInt) -> Self {
        self.gasPrice = gasPrice
        return self
    }

    func build() -> EthereumTransactionCandidate? {
        guard
            let to = to,
            let value = value,
            let gasPrice = gasPrice,
            let gasLimit = gasLimit
            else {
                return nil
        }
        return EthereumTransactionCandidate(
            to: to,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            data: data
        )
    }
}
