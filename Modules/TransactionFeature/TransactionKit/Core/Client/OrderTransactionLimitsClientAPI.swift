// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol OrderTransactionLimitsClientAPI {
    func fetchTransactionLimits(for fiatCurrency: FiatCurrency,
                                networkFee: FiatCurrency,
                                minorValues: Bool) -> Single<TransactionLimits>
}

