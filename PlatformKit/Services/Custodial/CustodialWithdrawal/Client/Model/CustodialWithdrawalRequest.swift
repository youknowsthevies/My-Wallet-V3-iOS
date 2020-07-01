//
//  CustodialWithdrawalRequest.swift
//  PlatformKit
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import Foundation

/// The `request` submitted for withdrawing custodial funds
/// from your custodial wallet to your non-custodial. The `address`
/// should be the corresponding non-custodial wallet.
public struct CustodialWithdrawalRequest: Encodable {
    public let address: String
    public let cryptoValue: CryptoValue
    
    enum CodingKeys: String, CodingKey {
        case address
        case currency
        case amount
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let currency = cryptoValue.code
        try container.encode(address, forKey: .address)
        try container.encode(currency, forKey: .currency)
        try container.encode(cryptoValue.value.amount.description, forKey: .amount)
    }
}
