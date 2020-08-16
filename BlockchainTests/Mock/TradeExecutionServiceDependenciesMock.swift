//
//  TradeExecutionServiceDependenciesMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
@testable import Blockchain
import ERC20Kit
import EthereumKit
import Foundation
@testable import PlatformKit
import RxSwift
import StellarKit
import stellarsdk

class TradeExecutionServiceDependenciesMock: TradeExecutionServiceDependenciesAPI {
    var assetAccountRepository: Blockchain.AssetAccountRepositoryAPI = AssetAccountRepositoryMock()
    var feeService: FeeServiceAPI = FeeServiceMock()
    var stellar: StellarDependenciesAPI = StellarDependenciesMock()
    var erc20Service: AnyERC20Service<PaxToken> = AnyERC20Service<PaxToken>(PaxERC20ServiceMock())
    var erc20AccountRepository: ERC20AssetAccountRepository<PaxToken> = ERC20AssetAccountRepository<PaxToken>(
        service: AnyAssetAccountDetailsAPI(service: ERC20AssetAccountDetailsAPIMock())
    )
    var ethereumWalletService: EthereumWalletServiceAPI = EthereumWalletServiceMock()
}
