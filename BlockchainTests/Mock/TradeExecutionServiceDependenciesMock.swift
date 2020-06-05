//
//  TradeExecutionServiceDependenciesMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import stellarsdk
@testable import Blockchain
@testable import PlatformKit
import BitcoinKit
import StellarKit
import EthereumKit
import ERC20Kit

class TradeExecutionServiceDependenciesMock: TradeExecutionServiceDependenciesAPI {
    var assetAccountRepository: Blockchain.AssetAccountRepositoryAPI = AssetAccountRepositoryMock()
    var feeService: FeeServiceAPI = FeeServiceMock()
    var stellar: StellarDependenciesAPI = StellarDependenciesMock()
    var erc20Service: AnyERC20Service<PaxToken> = AnyERC20Service<PaxToken>(PaxERC20ServiceMock())
    var erc20AccountRepository: AnyERC20AssetAccountRepository<PaxToken> = AnyERC20AssetAccountRepository<PaxToken>(ERC20AssetAccountRepositoryMock())
    var ethereumWalletService: EthereumWalletServiceAPI = EthereumWalletServiceMock()
}
