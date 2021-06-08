// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit

public extension ERC20Token {
    static var aave: ERC20Token { ERC20Token(cryptoCurrency: .erc20(.aave))! }
    static var pax: ERC20Token { ERC20Token(cryptoCurrency: .erc20(.pax))! }
    static var tether: ERC20Token { ERC20Token(cryptoCurrency: .erc20(.tether))! }
    static var wdgld: ERC20Token { ERC20Token(cryptoCurrency: .erc20(.wdgld))! }
    static var yearnFinance: ERC20Token { ERC20Token(cryptoCurrency: .erc20(.yearnFinance))! }
}

public struct ERC20Token {
    let assetType: CryptoCurrency
    let contractAddress: EthereumContractAddress
    let smallestSpendableValue: CryptoValue
    let nonCustodialTransactionSupport: AvailableActions
    var name: String {
        assetType.name
    }
    var metadataKey: String {
        assetType.code.lowercased()
    }

    fileprivate init?(cryptoCurrency: CryptoCurrency) {
        guard let contractAddress = cryptoCurrency.contractAddress else {
            return nil
        }
        assetType = cryptoCurrency
        self.contractAddress = EthereumContractAddress(stringLiteral: contractAddress)
        nonCustodialTransactionSupport = [.swap]
        smallestSpendableValue = CryptoValue(amount: 1, currency: cryptoCurrency)
    }

}
