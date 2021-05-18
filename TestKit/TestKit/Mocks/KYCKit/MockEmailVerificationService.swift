// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import KYCKit
import ToolKit

public final class MockEmailVerificationService: EmailVerificationServiceAPI {

    public struct RecordedInvocations {
        public var checkEmailVerificationStatus: [Void] = []
        public var sendVerificationEmail: [String] = []
        public var updateEmailAddress: [String] = []
    }

    public struct StubbedResults {
        public var checkEmailVerificationStatus: AnyPublisher<EmailVerificationStatus, EmailVerificationCheckError> = .just(.unverified)
        public var sendVerificationEmail: AnyPublisher<Void, UpdateEmailAddressError> = .just(())
        public var updateEmailAddress: AnyPublisher<Void, UpdateEmailAddressError> = .just(())
    }

    private(set) public var recordedInvocations = RecordedInvocations()
    public var stubbedResults = StubbedResults()

    public func checkEmailVerificationStatus() -> AnyPublisher<EmailVerificationStatus, EmailVerificationCheckError> {
        recordedInvocations.checkEmailVerificationStatus.append(())
        return stubbedResults.checkEmailVerificationStatus
    }

    public func sendVerificationEmail(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        recordedInvocations.sendVerificationEmail.append(emailAddress)
        return stubbedResults.sendVerificationEmail
    }

    public func updateEmailAddress(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        recordedInvocations.updateEmailAddress.append(emailAddress)
        return stubbedResults.updateEmailAddress
    }
}
