//
//  LInkedBanksClientAPI.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol LinkedBanksClientAPI: AnyObject {
    /// Retrieves any linked banks associated with the current user
    func linkedBanks() -> Single<[LinkedBankResponse]>

    /// Starts the proccess of creating a bank linkage
    /// - Parameter currency: A `FiatCurrency` value of the linked bank
    func createBankLinkage(for currency: FiatCurrency) -> Single<CreateBankLinkageResponse>
}
