// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import StellarKit

protocol StellarTransactionAPI {
    func send(_ paymentOperation: StellarPaymentOperation, sourceKeyPair: StellarKit.StellarKeyPair) -> Completable
}
