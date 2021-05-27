// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import KYCUIKit
import UIKit

public final class MockKYCRouter: KYCUIKit.Routing {

    public struct RecordedInvocations {
        public var routeToEmailVerification: [(emailAddress: String, flowCompletion: (FlowResult) -> Void)] = []
    }

    private(set) public var recordedInvocations = RecordedInvocations()

    public func routeToEmailVerification(from origin: UIViewController, emailAddress: String, flowCompletion: @escaping (FlowResult) -> Void) {
        recordedInvocations.routeToEmailVerification.append((emailAddress, flowCompletion))
    }
}
