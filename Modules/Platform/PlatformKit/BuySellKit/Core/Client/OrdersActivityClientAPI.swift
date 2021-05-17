// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol OrdersActivityClientAPI: class {

    /// Fetch order activity response
    func activityResponse(fiatCurrency: FiatCurrency, pendingOnly: Bool) -> Single<OrdersActivityResponse>
}
