// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxRelay
import RxSwift

@testable import Blockchain

final class MockSendFeeService: SendFeeServicing {
    
    var fee: Observable<CryptoValue> {
        let value = self.expectedValue
        return triggerRelay
            .map { _ in value }
            .startWith(value)
    }
    
    let triggerRelay = PublishRelay<Void>()
    
    private let expectedValue: CryptoValue
    
    init(expectedValue: CryptoValue) {
        self.expectedValue = expectedValue
    }
}
