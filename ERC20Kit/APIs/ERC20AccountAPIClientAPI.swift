//
//  ERC20AccountAPIClientAPI.swift
//  ERC20Kit
//
//  Created by Jack on 16/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift

public protocol ERC20AccountAPIClientAPI {
    associatedtype Token: ERC20Token

    func fetchTransactions(from address: String, page: String) -> Single<ERC20TransfersResponse<Token>>
    func fetchAccountSummary(from address: String) -> Single<ERC20AccountSummaryResponse<Token>>
}
