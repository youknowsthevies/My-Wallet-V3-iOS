// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxRelay
import RxSwift

final class MockPairExchangeService: PairExchangeServiceAPI {

    var fiatPrice: Observable<FiatValue> {
        let value = self.expectedValue
        return fetchTriggerRelay
            .map { _ in value }
            .startWith(value)
    }
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    private let expectedValue: FiatValue
    
    init(expectedValue: FiatValue) {
        self.expectedValue = expectedValue
    }
}
