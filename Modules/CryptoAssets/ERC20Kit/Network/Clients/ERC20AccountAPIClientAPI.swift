// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift

protocol ERC20AccountAPIClientAPI {
    func fetchTransactions(from address: String, page: String, contractAddress: String) -> Single<ERC20TransfersResponse>
    func fetchAccountSummary(from address: String, contractAddress: String) -> Single<ERC20AccountSummaryResponse>
    func isContract(address: String) -> Single<ERC20IsContractResponse>
}
