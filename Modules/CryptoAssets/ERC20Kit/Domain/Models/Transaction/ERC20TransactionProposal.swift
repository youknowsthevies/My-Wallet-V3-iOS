// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import EthereumKit

public enum ERC20TransactionEvaluationResult<Token: ERC20Token> {
    case valid(ERC20TransactionProposal<Token>)
    case invalid(ERC20ValidationError)
}

public struct ERC20TransactionProposal<Token: ERC20Token> {
    
    public var aboveMinimumSpendable: Bool {
        value.amount >= Token.smallestSpendableValue.amount
    }
    
    public let from: EthereumAddress
    public let gasPrice: BigUInt
    public let gasLimit: BigUInt
    public let value: ERC20TokenValue<Token>
    
    public init(from: EthereumAddress,
                gasPrice: BigUInt,
                gasLimit: BigUInt,
                value: ERC20TokenValue<Token>) {
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
    }
}

extension ERC20TransactionProposal: Equatable {
    public static func == (lhs: ERC20TransactionProposal, rhs: ERC20TransactionProposal) -> Bool {
        lhs.from == rhs.from &&
            lhs.gasLimit == rhs.gasLimit
            && lhs.gasPrice == rhs.gasPrice
            && lhs.value.value == rhs.value.value
    }
}
