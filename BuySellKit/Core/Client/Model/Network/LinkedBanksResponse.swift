//
//  LinkedBanksResponse.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct LinkedBankResponse: Decodable {
    struct Details: Decodable {
        let bankAccountType: String
        let bankName: String
        let accountName: String
        let accountNumber: String
        let routingNumber: String
    }
    let id: String
    let currency: String
    let partner: String
    let state: PaymentAccountProperty.State
    let details: Details
}
