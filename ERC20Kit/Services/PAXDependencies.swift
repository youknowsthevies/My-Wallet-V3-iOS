//
//  PAXDependencies.swift
//  ERC20Kit
//
//  Created by Dimitrios Chatzieleftheriou on 23/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import PlatformKit

public protocol PAXDependencies {
    var assetAccountRepository: ERC20AssetAccountRepository<PaxToken> { get }
    var historicalTransactionService: AnyERC20HistoricalTransactionService<PaxToken> { get }
    var paxService: ERC20Service<PaxToken> { get }
    var walletService: EthereumWalletServiceAPI { get }
    var feeService: AnyCryptoFeeService<EthereumTransactionFee> { get }
}
