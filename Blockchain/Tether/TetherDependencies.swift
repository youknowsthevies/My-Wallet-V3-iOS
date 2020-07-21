//
//  TetherDependencies.swift
//  Blockchain
//
//  Created by Paulo on 01/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ERC20Kit
import PlatformKit

public protocol TetherDependencies {
    var assetAccountRepository: ERC20AssetAccountRepository<TetherToken> { get }
    var historicalTransactionService: AnyERC20HistoricalTransactionService<TetherToken> { get }
}

