// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import TransactionUIKit

final class TransactionsKYCAdapter {

    private let kycTiersService: KYCTiersServiceAPI

    init(
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.kycTiersService = kycTiersService
    }
}

extension TransactionsKYCAdapter: TransactionUIKit.KYCSDDServiceAPI {

    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never> {
        kycTiersService.checkSimplifiedDueDiligenceEligibility()
    }

    func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<Bool, Never> {
        kycTiersService.checkSimplifiedDueDiligenceVerification()
    }
}
