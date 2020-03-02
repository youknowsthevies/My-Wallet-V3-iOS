//
//  SimpleBuyQuoteClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyQuoteClientAPI: class {
    func getQuote(for action: SimpleBuyOrder.Action,
                  to cryptoCurrency: CryptoCurrency,
                  amount: FiatValue,
                  token: String) -> Single<SimpleBuyQuoteResponse>
}
