//
//  WithdrawalClientAPI.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 19/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol WithdrawalClientAPI: AnyObject {
    /// Requests the withdraw fee for the requested currency
    ///
    /// - parameter currency: A `FiatCurrency` value, for the request
    /// - Returns: A `Single<MoneyValue>` object with the fetched fee value
    func withdrawFee(currency: FiatCurrency) -> Single<WithdrawFeesResponse>
}
