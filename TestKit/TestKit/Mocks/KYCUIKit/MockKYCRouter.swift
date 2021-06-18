// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import KYCUIKit
import UIKit

public final class MockKYCRouter: KYCUIKit.Routing {

    public struct RecordedInvocations {
        public var routeToEmailVerification: [(emailAddress: String, flowCompletion: (FlowResult) -> Void)] = []
        public var routeToKYC: [(presenter: UIViewController, flowCompletion: (FlowResult) -> Void)] = []
        public var presentEmailVerificationAndKYCIfNeeded: [(UIViewController)] = []
        public var presentEmailVerificationIfNeeded: [(UIViewController)] = []
        public var presentKYCIfNeeded: [(UIViewController)] = []
    }

    public struct StubbedResults {
        public var presentEmailVerificationAndKYCIfNeeded: AnyPublisher<FlowResult, RouterError> = .failure(.emailVerificationFailed)
        public var presentEmailVerificationIfNeeded: AnyPublisher<FlowResult, RouterError> = .failure(.emailVerificationFailed)
        public var presentKYCIfNeeded: AnyPublisher<FlowResult, RouterError> = .failure(.kycVerificationFailed)
    }

    private(set) public var recordedInvocations = RecordedInvocations()
    public var stubbedResults = StubbedResults()

    public func routeToEmailVerification(from origin: UIViewController, emailAddress: String, flowCompletion: @escaping (FlowResult) -> Void) {
        recordedInvocations.routeToEmailVerification.append((emailAddress, flowCompletion))
    }

    public func routeToKYC(from presenter: UIViewController, flowCompletion: @escaping (FlowResult) -> Void) {
        recordedInvocations.routeToKYC.append((presenter, flowCompletion))
    }

    public func presentEmailVerificationAndKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError> {
        recordedInvocations.presentEmailVerificationAndKYCIfNeeded.append((presenter))
        return stubbedResults.presentEmailVerificationAndKYCIfNeeded
    }

    public func presentEmailVerificationIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError> {
        recordedInvocations.presentEmailVerificationIfNeeded.append((presenter))
        return stubbedResults.presentEmailVerificationIfNeeded
    }

    public func presentKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError> {
        recordedInvocations.presentKYCIfNeeded.append((presenter))
        return stubbedResults.presentKYCIfNeeded
    }
}
