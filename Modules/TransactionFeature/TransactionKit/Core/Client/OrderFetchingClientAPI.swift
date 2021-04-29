// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol OrderFetchingClientAPI {
    func fetchTransaction(with transactionId: String) -> Single<SwapActivityItemEvent>
}
