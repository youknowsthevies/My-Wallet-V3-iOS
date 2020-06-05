//
//  ERC20AccountAPIClientMock.swift
//  ERC20KitTests
//
//  Created by Jack on 23/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift

class ERC20AccountAPIClientMock: ERC20AccountAPIClientAPI {
    typealias Token = PaxToken

    var fetchTransactionsResponse: Single<ERC20TransfersResponse<PaxToken>> = .just(.transfersResponse)
    func fetchTransactions(from address: String, page: String) -> Single<ERC20TransfersResponse<PaxToken>> {
        fetchTransactionsResponse
    }

    var fetchAccountSummaryResponse: Single<ERC20AccountSummaryResponse<PaxToken>> = .just(.accountResponseMock)
    func fetchAccountSummary(from address: String) -> Single<ERC20AccountSummaryResponse<PaxToken>> {
        fetchAccountSummaryResponse
    }
}
