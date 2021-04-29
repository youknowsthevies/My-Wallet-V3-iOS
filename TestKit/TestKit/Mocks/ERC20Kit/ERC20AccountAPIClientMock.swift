// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift

class ERC20AccountAPIClientMock: ERC20AccountAPIClientAPI {
    typealias Token = PaxToken

    var fetchTransactionsResponse: Single<ERC20TransfersResponse<PaxToken>> = .just(.transfersResponse)
    func fetchTransactions(from address: String, page: String) -> Single<ERC20TransfersResponse<PaxToken>> {
        fetchTransactionsResponse
    }
    
    func isContract(address: String) -> Single<ERC20IsContractResponse<Token>> {
        .just(ERC20IsContractResponse<Token>(contract: false))
    }
    
    var fetchAccountSummaryResponse: Single<ERC20AccountSummaryResponse<PaxToken>> = .just(.accountResponseMock)
    func fetchAccountSummary(from address: String) -> Single<ERC20AccountSummaryResponse<PaxToken>> {
        fetchAccountSummaryResponse
    }
}
