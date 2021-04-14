//
//  ERC20TransfersResponseMock.swift
//  ERC20KitTests
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import ERC20Kit
import EthereumKit
import PlatformKit

extension ERC20TransfersResponse where Token == PaxToken {
    static var transfersResponse: ERC20TransfersResponse {
        ERC20TransfersResponse(transactions: [])
    }
}
