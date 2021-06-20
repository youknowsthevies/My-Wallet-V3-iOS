// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import OnboardingUIKit
import ToolKit
import UIKit

final class MockOnboardingEmailVerificationRouter: OnboardingUIKit.EmailVerificationRouterAPI {

    struct RecordedInvocations {
        var presentEmailVerification: [UIViewController] = []
    }

    struct StubbedResults {
        var presentEmailVerification: AnyPublisher<OnboardingResult, Never> = .just(.abandoned)
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        recordedInvocations.presentEmailVerification.append(presenter)
        return stubbedResults.presentEmailVerification
    }
}
