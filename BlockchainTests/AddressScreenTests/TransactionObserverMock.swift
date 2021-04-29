// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

@testable import Blockchain

struct TransactionObserverMock: TransactionObserving {
    
    let paymentDetails: ReceivedPaymentDetails
    
    var paymentReceived: Observable<ReceivedPaymentDetails> {
        .just(paymentDetails)
    }
}
