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
    
    let identifier: String
    
    init?(response: BeneficiaryResponse) {
        self.identifier = response.id
        self.name = response.name
        guard let currency = FiatCurrency(code: response.currency) else {
            return nil
        }
        self.currency = currency
    }
}
