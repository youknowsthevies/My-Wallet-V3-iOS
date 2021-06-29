// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public protocol FiatWithdrawRepositoryAPI {

    func createWithdrawOrder(id: String, amount: MoneyValue) -> Completable
}
