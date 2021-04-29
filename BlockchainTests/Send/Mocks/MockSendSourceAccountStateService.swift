// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

@testable import Blockchain

final class MockSendSourceAccountStateService: SendSourceAccountStateServicing {

    let stateRawValue: SendSourceAccountState
    
    var state: Observable<SendSourceAccountState> {
        Observable.just(stateRawValue)
    }

    func recalculateState() { }
    
    init(stateRawValue: SendSourceAccountState) {
        self.stateRawValue = stateRawValue
    }
}
