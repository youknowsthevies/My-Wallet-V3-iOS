// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol OrderCancellationClientAPI: class {
    /// Cancels an order with a given identifier
    func cancel(order id: String) -> Completable
}
