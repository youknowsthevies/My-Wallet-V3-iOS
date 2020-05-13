//
//  ERC20AccountResponseMock.swift
//  ERC20KitTests
//
//  Created by Paulo on 27/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ERC20Kit
import EthereumKit
import PlatformKit

extension ERC20AccountResponse where Token == PaxToken {
    static var accountResponseMock: ERC20AccountResponse {
        ERC20AccountResponse(
            currentPage: 0,
            fromAddress: EthereumAddress(stringLiteral: ""),
            pageSize: 0,
            transactions: [],
            balance: CryptoValue.paxFromMajor(string: "2.0")!.amount.string(unitDecimals: 0),
            decimals: 0,
            tokenHash: ""
        )
    }
}
