// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol FiatActivityItemEventFetcherAPI: class {
    func fiatActivity(fiatCurrency: FiatCurrency) -> Single<[FiatActivityItemEvent]>
}
