//
//  EthereumAccountBalanceService.swift
//  EthereumKit
//
//  Created by Paulo on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BigInt
import PlatformKit
import RxSwift

protocol EthereumAccountBalanceServiceAPI {
    func balance(for address: String) -> Single<CryptoValue>
}

class EthereumAccountBalanceService: EthereumAccountBalanceServiceAPI {

    private let client: APIClientAPI

    init(client: APIClientAPI = resolve()) {
        self.client = client
    }

    func balance(for address: String) -> Single<CryptoValue> {
        client
            .balanceDetails(from: address)
            .map(\.cryptoValue)
    }
}
