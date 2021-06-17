// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public protocol OrdersActivityEventServiceAPI: AnyObject {
    func activityResponse(fiatCurrency: FiatCurrency) -> Single<OrdersActivityResponse>
}

final class OrdersActivityEventService: OrdersActivityEventServiceAPI {

    private let client: OrdersActivityClientAPI

    init(client: SimpleBuyClientAPI = resolve()) {
        self.client = client
    }

    func activityResponse(fiatCurrency: FiatCurrency) -> Single<OrdersActivityResponse> {
        /// We want all activity including pending transactions.
        client.activityResponse(fiatCurrency: fiatCurrency, pendingOnly: false)
    }
}
