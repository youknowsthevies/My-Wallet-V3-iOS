//
//  LinkedBanksService.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public protocol LinkedBanksServiceAPI {
    var linkedBanks: Single<[LinkedBankData]> { get }
}

final class LinkedBanksService: LinkedBanksServiceAPI {

    var linkedBanks: Single<[LinkedBankData]> {
        cachedValue.valueSingle
    }

    private let cachedValue: CachedValue<[LinkedBankData]>

    // MARK: - Injected
    private let client: LinkedBanksClientAPI

    init(client: LinkedBanksClientAPI = resolve()) {
        self.client = client

        cachedValue = CachedValue<[LinkedBankData]>(configuration: .onSubscription())

        cachedValue.setFetch {
            client.linkedBanks()
                .map { response -> [LinkedBankData] in
                    response.compactMap(LinkedBankData.init(response:))
                }
        }
    }
}
