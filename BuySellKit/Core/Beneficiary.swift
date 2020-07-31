//
//  Beneficiary.swift
//  BuySellKit
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct Beneficiary {

    public let currency: FiatCurrency
    public let name: String
    public let identifier: String
    public let account: String
    public let limit: FiatValue?
    
    init?(response: BeneficiaryResponse, limit: FiatValue?) {
        self.identifier = response.id
        self.name = response.name
        var address = response.address
        address.removeAll { $0 == "*" }
        self.account = address
        self.limit = limit
        
        guard let currency = FiatCurrency(code: response.currency) else {
            return nil
        }
        self.currency = currency
    }
}

extension Beneficiary: Equatable {
    public static func == (lhs: Beneficiary, rhs: Beneficiary) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
