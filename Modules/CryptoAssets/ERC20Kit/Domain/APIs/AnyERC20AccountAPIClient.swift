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

final class AnyERC20AccountAPIClient<Token: ERC20Token>: ERC20AccountAPIClientAPI {

    private let fetchTransactions: (String, String) -> Single<ERC20TransfersResponse<Token>>
    private let fetchAccountSummary: (String) -> Single<ERC20AccountSummaryResponse<Token>>
    private let isContract: (String) -> Single<ERC20IsContractResponse<Token>>

    init<APIClient: ERC20AccountAPIClientAPI>(accountAPIClient: APIClient) where APIClient.Token == Token {
        fetchTransactions = accountAPIClient.fetchTransactions
        fetchAccountSummary = accountAPIClient.fetchAccountSummary
        isContract = accountAPIClient.isContract
    }

    func fetchTransactions(from address: String, page: String) -> Single<ERC20TransfersResponse<Token>> {
        fetchTransactions(address, page)
    }
    
    func isContract(address: String) -> Single<ERC20IsContractResponse<Token>> {
        isContract(address)
    }

    func fetchAccountSummary(from address: String) -> Single<ERC20AccountSummaryResponse<Token>> {
        fetchAccountSummary(address)
    }
}
