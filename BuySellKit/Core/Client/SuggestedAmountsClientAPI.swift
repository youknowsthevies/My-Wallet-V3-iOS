//
//  SuggestedAmountsClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 29/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol SuggestedAmountsClientAPI: class {
    func suggestedAmounts(for currency: FiatCurrency,
                          using token: String) -> Single<SuggestedAmountsResponse>
}
