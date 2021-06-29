// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public protocol OrderFetchingRepositoryAPI {

    func fetchTransaction(
        with transactionId: String
    ) -> Single<SwapActivityItemEvent>

    func fetchTransactionStatus(
        with transactionId: String
    ) -> Single<SwapActivityItemEvent.EventStatus>
}
