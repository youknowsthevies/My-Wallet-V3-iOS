// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import EthereumKit
import PlatformKit

public protocol ERC20Token {

    static var assetType: CryptoCurrency { get }
    static var name: String { get }
    static var metadataKey: String { get }
    static var contractAddress: EthereumContractAddress { get }
    static var smallestSpendableValue: ERC20TokenValue<Self> { get }
    static var zeroValue: ERC20TokenValue<Self> { get }
    /// Indicates which non custodial transaction actions using this Token are supported.
    static var nonCustodialTransactionSupport: AvailableActions { get }
    
    static func cryptoValueFrom(majorValue: String) -> ERC20TokenValue<Self>?
    
    static func cryptoValueFrom(minorValue: String) -> ERC20TokenValue<Self>?
    static func cryptoValueFrom(minorValue: BigInt) -> ERC20TokenValue<Self>?
}

extension ERC20Token {

    public static var name: String {
        assetType.name
    }
    
    public static var metadataKey: String {
        assetType.rawValue.lowercased()
    }
    
    public static var zeroValue: ERC20TokenValue<Self> {
        // swiftlint:disable:next force_try
        return try! ERC20TokenValue<Self>(crypto: CryptoValue.zero(currency: assetType))
    }

    public static func cryptoValueFrom(minorValue: BigInt) -> ERC20TokenValue<Self>? {
        try? ERC20TokenValue<Self>(crypto: CryptoValue.create(minor: minorValue, currency: assetType))
    }

    public static func cryptoValueFrom(majorValue: String) -> ERC20TokenValue<Self>? {
        guard let cryptoValue = CryptoValue.create(major: majorValue, currency: assetType) else {
            return nil
        }
        return try? ERC20TokenValue<Self>(crypto: cryptoValue)
    }

    public static func cryptoValueFrom(minorValue: String) -> ERC20TokenValue<Self>? {
        guard let minorBigInt = BigInt(minorValue) else {
            return nil
        }
        return try? ERC20TokenValue<Self>(crypto: CryptoValue.create(minor: minorBigInt, currency: assetType))
    }
}
