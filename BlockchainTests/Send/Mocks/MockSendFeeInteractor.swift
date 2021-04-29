// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

@testable import Blockchain
import PlatformKit

final class MockSendFeeInteractor: SendFeeInteracting {
    
    private let expectedState: MoneyValuePairCalculationState
    
    init(expectedState: MoneyValuePairCalculationState) {
        self.expectedState = expectedState
    }
    
    /// Stream of the updated balance in account
    var calculationState: Observable<MoneyValuePairCalculationState> {
        Observable.just(expectedState)
    }
}
