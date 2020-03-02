//
//  SimpleBuyOrderQuoteServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyOrderQuoteServiceAPI: class {
    func getQuote(for action: SimpleBuyOrder.Action,
                  using checkoutData: SimpleBuyCheckoutData) -> Single<SimpleBuyQuote>
}
