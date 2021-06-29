// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol TransactionLimitsRepositoryAPI {

    func fetchTransactionLimits(currency: CurrencyType,
                                networkFee: CurrencyType,
                                product: TransactionLimitsProduct) -> Single<TransactionLimits>
}

