//
//  CustodialWithdrawalResponse.swift
//  PlatformKit
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The response object returned after submitting a `SimpleBuyWithdrawalRequest`.
/// At the time of writing, `Status`/`State` is not exposed to clients.
public struct CustodialWithdrawalResponse: Decodable {
    
    public enum Status: String {
        case none
        case pending
        case refunded
        case complete
        case rejected
    }
    
    public let identifier: String
    public let userId: String
    public let cryptoValue: CryptoValue
    
    /// NOTE: `State`/`Status` is not mapped yet as it is not exposed
    /// by the API. However, it may well be in the future so as
    /// we can show the status of the withdrawal after submission. 
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case amount
        case symbol
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .id)
        userId = try values.decode(String.self, forKey: .user)
        let amountContainer = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .amount)
        let symbol = try amountContainer.decode(String.self, forKey: .symbol)
        let value = try amountContainer.decode(String.self, forKey: .value)
        guard let currency = CryptoCurrency(rawValue: symbol) else { throw PlatformKitError.default }
        cryptoValue = CryptoValue.createFromMajorValue(string: value, assetType: currency) ?? CryptoValue.zero(assetType: currency)
    }
}
