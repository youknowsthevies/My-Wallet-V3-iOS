//
//  SendPaxViewModel.swift
//  Blockchain
//
//  Created by AlexM on 5/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ERC20Kit
import EthereumKit
import Foundation
import PlatformKit

struct SendPaxViewModel {
    var walletLabel: String?
    var addressStatus = AddressStatus.empty
    var paxAmount: ERC20TokenValue<PaxToken>
    var fiatAmount: FiatValue
    var proposal: ERC20TransactionProposal<PaxToken>?
    var internalError: SendMoniesInternalError?
    
    var input: SendPaxInput {
        SendPaxInput(
            addressStatus: addressStatus,
            paxAmount: paxAmount,
            fiatAmount: fiatAmount
        )
    }
    
    init(input: SendPaxInput = .empty) {
        self.addressStatus = input.addressStatus
        self.paxAmount = input.paxAmount
        self.fiatAmount = input.fiatAmount
    }
    
    mutating func updateWalletLabel(with tokenAccount: ERC20TokenAccount?) {
        if let tokenAccount = tokenAccount {
            walletLabel = tokenAccount.label
        }
    }
    
    var description: String {
        "address: \(addressStatus) \n paxAmount: \(paxAmount.toDisplayString(includeSymbol: false, locale: Locale.current)) \n \(fiatAmount.displayString) \n internalError: \(String(describing: internalError))"
    }
}
