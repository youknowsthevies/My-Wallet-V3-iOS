// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardAdditionClientAPI: class {
    func add(for currency: String,
             email: String,
             billingAddress: CardPayload.BillingAddress) -> Single<CardPayload>
}
