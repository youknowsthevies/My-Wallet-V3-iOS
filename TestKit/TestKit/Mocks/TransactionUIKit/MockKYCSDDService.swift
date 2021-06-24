// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import TransactionUIKit

final class MockKYCSDDService: KYCSDDServiceAPI {

    struct StubbedResults {
        var checkSimplifiedDueDiligenceEligibility: AnyPublisher<Bool, Never> = .just(false)
        var checkSimplifiedDueDiligenceVerification: AnyPublisher<Bool, Never> = .just(false)
    }

    var stubbedResults = StubbedResults()

    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never> {
        stubbedResults.checkSimplifiedDueDiligenceEligibility
    }

    func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<Bool, Never> {
        stubbedResults.checkSimplifiedDueDiligenceVerification
    }
}
