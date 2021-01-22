//
//  ERC20IsContractResponse.swift
//  ERC20Kit
//
//  Created by Jack Pooley on 20/01/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ERC20IsContractResponse<Token: ERC20Token>: Decodable {
    let contract: Bool
}
