// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol OrderTransactionLimitsClientAPI {
    func fetchTransactionLimits(currency: CurrencyType,
                                networkFee: CurrencyType,
                                product: TransactionLimitsProduct) -> Single<TransactionLimits>
}
