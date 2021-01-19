//
//  OrderTransactionLimitsClientAPI.swift
//  TransactionKit
//
//  Created by Alex McGregor on 11/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol OrderTransactionLimitsClientAPI {
    func fetchTransactionLimits(for fiatCurrency: FiatCurrency,
                                networkFee: FiatCurrency,
                                minorValues: Bool) -> Single<TransactionLimits>
}

