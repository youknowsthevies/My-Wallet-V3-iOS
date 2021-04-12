//
//  InternalTransferRequest.swift
//  TransactionKit
//
//  Created by Alex McGregor on 2/3/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit

/// The `InternalTransferRequest` submitted for transferring custodial funds
/// from your custodial wallet to your non-custodial. The `address`
/// should be the corresponding non-custodial wallet.
public struct InternalTransferRequest: Encodable {
    public let address: String
    public let moneyValue: MoneyValue

    enum CodingKeys: String, CodingKey {
        case address
        case currency
        case amount
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let currency = moneyValue.code
        try container.encode(address, forKey: .address)
        try container.encode(currency, forKey: .currency)
        try container.encode(moneyValue.value.amount.description, forKey: .amount)
    }
}
