//
//  ERC20AccountSummaryResponse.swift
//  ERC20Kit
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct ERC20AccountSummaryResponse<Token: ERC20Token>: Decodable {
    let balance: String
}
