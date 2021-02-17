//
//  ERC20ContractGasActivityModel.swift
//  ERC20Kit
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import EthereumKit
import PlatformKit

public struct ERC20ContractGasActivityModel {

    public let cryptoCurrency: CryptoCurrency
    public let cryptoValue: CryptoValue?
    public let to: EthereumAddress?

    public init?(details: EthereumActivityItemEventDetails) {
        guard let cryptoCurrency = ERC20ContractGasActivityModel.token(address: details.to)
            else { return nil }
        self.cryptoCurrency = cryptoCurrency
        switch ERC20Function(data: details.data) {
        case .transfer(to: let address, amount: let hexAmount):
            cryptoValue = ERC20ContractGasActivityModel.gasCryptoValue(hexAmount: hexAmount, cryptoCurrency: cryptoCurrency)
            self.to = .init(stringLiteral: address)
        case nil:
            cryptoValue = nil
            to = nil
        }
    }

    private static func gasCryptoValue(hexAmount: String?, cryptoCurrency: CryptoCurrency) -> CryptoValue? {
        guard let hexAmount = hexAmount,
            let decimalAmount = BigInt(hexAmount, radix: 16)
            else { return nil }
        return CryptoValue.create(minor: decimalAmount, currency: cryptoCurrency)
    }

    private static func token(address: EthereumAddress) -> CryptoCurrency? {
        if address.publicKey.compare(PaxToken.contractAddress.publicKey, options: .caseInsensitive) == .orderedSame {
            return .pax
        } else if address.publicKey.compare(TetherToken.contractAddress.publicKey, options: .caseInsensitive) == .orderedSame {
            return .tether
        } else if address.publicKey.compare(WDGLDToken.contractAddress.publicKey, options: .caseInsensitive) == .orderedSame {
           return .wDGLD
        }
        return nil
    }
}
