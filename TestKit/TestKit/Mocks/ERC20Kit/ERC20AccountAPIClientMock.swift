// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift

class ERC20AccountAPIClientMock: ERC20AccountAPIClientAPI {

    var isContractResponse: Single<ERC20IsContractResponse> = .just(ERC20IsContractResponse(contract: false))
    var fetchTransactionsResponse: Single<ERC20TransfersResponse> = .just(.transfersResponse)
    var fetchAccountSummaryResponse: Single<ERC20AccountSummaryResponse>

    init(cryptoCurrency: CryptoCurrency) {
        fetchAccountSummaryResponse = .just(.accountResponseMock(cryptoCurrency: cryptoCurrency))
    }

    func fetchTransactions(from address: String, page: String?, contractAddress: String) -> Single<ERC20TransfersResponse> {
        fetchTransactionsResponse
    }

    func isContract(address: String) -> Single<ERC20IsContractResponse> {
        isContractResponse
    }

    func fetchAccountSummary(from address: String, contractAddress: String) -> Single<ERC20AccountSummaryResponse> {
        fetchAccountSummaryResponse
    }
}
