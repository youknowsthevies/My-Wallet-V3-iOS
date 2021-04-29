// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol SuggestedAmountsClientAPI: class {
    func suggestedAmounts(for currency: FiatCurrency) -> Single<SuggestedAmountsResponse>
}
