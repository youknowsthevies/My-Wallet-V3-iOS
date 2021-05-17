// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

final class OrdersFiatActivityItemEventService: FiatActivityItemEventFetcherAPI {

    private let service: OrdersActivityEventServiceAPI

    init(service: OrdersActivityEventServiceAPI = resolve()) {
        self.service = service
    }

    func fiatActivity(fiatCurrency: FiatCurrency) -> Single<[FiatActivityItemEvent]> {
        service.activityResponse(fiatCurrency: fiatCurrency)
            .map { $0.items }
    }
}
