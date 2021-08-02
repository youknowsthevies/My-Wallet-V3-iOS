// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol OrderCreationRepositoryAPI {

    func createOrder(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        destinationAddress: String?,
        refundAddress: String?
    ) -> Single<SwapOrder>
}

public protocol OrderUpdateRepositoryAPI {

    func updateOrder(
        identifier: String,
        success: Bool
    ) -> Completable
}
