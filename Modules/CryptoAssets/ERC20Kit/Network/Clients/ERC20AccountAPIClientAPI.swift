// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift

protocol ERC20AccountAPIClientAPI {
    associatedtype Token: ERC20Token

    func fetchTransactions(from address: String, page: String) -> Single<ERC20TransfersResponse<Token>>
    func fetchAccountSummary(from address: String) -> Single<ERC20AccountSummaryResponse<Token>>
    func isContract(address: String) -> Single<ERC20IsContractResponse<Token>>
}
