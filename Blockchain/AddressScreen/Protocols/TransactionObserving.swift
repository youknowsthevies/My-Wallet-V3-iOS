// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

protocol TransactionObserving {

    /// Streams received payments
    var paymentReceived: Observable<ReceivedPaymentDetails> { get }
}
