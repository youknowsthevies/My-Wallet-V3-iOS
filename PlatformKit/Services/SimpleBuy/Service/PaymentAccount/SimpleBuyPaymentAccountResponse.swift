//
//  SimpleBuyPaymentAccountResponse.swift
//  PlatformKit
//
//  Created by Paulo on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SimpleBuyPaymentAccountResponse: Decodable {
    struct Agent: Decodable {
        let account: String?
        let address: String?
        let code: String?
        let country: String?
        let name: String?
        let recipient: String?
        let routingNumber: String?
    }
    let id: String
    let address: String?
    let agent: Agent
    let currency: FiatCurrency
    let state: SimpleBuyPaymentAccountProperty.State
}
