//
//  SendPaxInput.swift
//  Blockchain
//
//  Created by AlexM on 5/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ERC20Kit
import EthereumKit
import Foundation
import PlatformKit

struct SendPaxInput {
    var addressStatus: AddressStatus
    var paxAmount: ERC20TokenValue<PaxToken>
    var fiatAmount: FiatValue
    
    init(addressStatus: AddressStatus = .empty,
         paxAmount: ERC20TokenValue<PaxToken>,
         fiatAmount: FiatValue) {
        self.addressStatus = addressStatus
        self.paxAmount = paxAmount
        self.fiatAmount = fiatAmount
    }
}

extension SendPaxInput {
    static let empty = SendPaxInput(
        paxAmount: .zero(),
        fiatAmount: .zero(currencyCode: BlockchainSettings.App.shared.fiatCurrencyCode)
    )
}
