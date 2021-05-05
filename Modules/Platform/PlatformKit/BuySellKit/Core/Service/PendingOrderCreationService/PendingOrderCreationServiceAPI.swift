// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol PendingOrderCreationServiceAPI: class {
    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<PendingConfirmationCheckoutData>
}
