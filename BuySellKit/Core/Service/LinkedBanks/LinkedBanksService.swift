//
//  LinkedBanksService.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol LinkedBanksServiceAPI {
    /// Fetches any linked bank associated with the current user
    var linkedBanks: Single<[LinkedBankData]> { get }

    /// Starts the flow to linked a bank
    var bankLinkageStartup: Single<BankLinkageData?> { get }
}

final class LinkedBanksService: LinkedBanksServiceAPI {

    var linkedBanks: Single<[LinkedBankData]> {
        cachedValue.valueSingle
    }

    let bankLinkageStartup: Single<BankLinkageData?>

    // MARK: - Private
    private let cachedValue: CachedValue<[LinkedBankData]>

    // MARK: - Injected
    private let client: LinkedBanksClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    init(client: LinkedBanksClientAPI = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        self.client = client
        self.fiatCurrencyService = fiatCurrencyService

        cachedValue = CachedValue<[LinkedBankData]>(configuration: .onSubscription())

        cachedValue.setFetch {
            client.linkedBanks()
                .map { response -> [LinkedBankData] in
                    response.compactMap(LinkedBankData.init(response:))
                }
        }

        bankLinkageStartup = fiatCurrencyService.fiatCurrency
            .flatMap { currency -> Single<CreateBankLinkageResponse> in
                client.createBankLinkage(for: currency)
            }
            .map(BankLinkageData.init(from:))
    }
}

