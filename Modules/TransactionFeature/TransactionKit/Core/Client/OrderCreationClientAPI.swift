// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol OrderCreationClientAPI {
    func create(with orderRequest: OrderCreationRequest) -> Single<SwapActivityItemEvent>
}

protocol OrderUpdateClientAPI {
    func updateOrder(with transactionId: String, updateRequest: OrderUpdateRequest) -> Completable
}
