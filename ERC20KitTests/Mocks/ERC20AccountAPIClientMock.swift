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

    var fetchWalletAccountResponse = Single<ERC20AccountResponse<PaxToken>>.just(ERC20AccountResponse<PaxToken>.accountResponseMock)
    func fetchWalletAccount(from address: String, page: String) -> Single<ERC20AccountResponse<PaxToken>> {
        fetchWalletAccountResponse
    }
}
