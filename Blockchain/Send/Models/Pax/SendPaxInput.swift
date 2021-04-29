// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
        fiatAmount: .zero(currency: BlockchainSettings.App.shared.fiatCurrency)!
    )
}
