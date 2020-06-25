//
//  QuoteClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol QuoteClientAPI: class {
    func getQuote(for action: Order.Action,
                  to cryptoCurrency: CryptoCurrency,
                  amount: FiatValue,
                  token: String) -> Single<QuoteResponse>
}
