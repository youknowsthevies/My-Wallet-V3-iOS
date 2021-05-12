// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import PlatformKit
import ToolKit

public enum EmailVerificationCheckError: Error, Equatable {
    case nabuError(NabuNetworkError)
}

public enum UpdateEmailAddressError: Error, Equatable {
    case missingCredentials
    case networkError(NetworkError)
}

/// An type representing the email verification status of a user using a nomenclature that's semantically closer to the business domain
public enum EmailVerificationStatus: Equatable {
    case verified, unverified
}

/// `EmainVerificationService` is the interface the UI should use to interface to the email verification APIs.
public protocol EmailVerificationServiceAPI {
    
    /// Fetches the current user's email verification status
    /// - Returns: A Combine `Publisher` that emits an `EmailVerificationStatus` on success or a `ServiceError` on failure
    func checkEmailVerificationStatus() -> AnyPublisher<EmailVerificationStatus, EmailVerificationCheckError>
    
    /// Re-sends a verification email to the passed-in `emailAddress
    /// - Parameter emailAddress: The email address of the user.
    /// - Returns: A Combine `Publisher` that emits no value on success or a `ServiceError` on failure
    func sendVerificationEmail(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError>
    
    /// Updates the user's email address to the passed-in value. This action will also invalidate the email verification status of a user and send a verification email to the new address.
    /// - Parameter emailAddress: The email address of the user.
    /// - Returns: A Combine `Publisher` that emits no value on success or a `ServiceError` on failure
    func updateEmailAddress(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError>
}

/// An implementation of `EmailVerificationServiceAPI`
public class EmailVerificationService: EmailVerificationServiceAPI {
    
    private let kycClient: KYCClientAPI
    private let emailService: EmailSettingsServiceAPI
    
    public init(
        kycClient: KYCClientAPI = resolve(),
        emailService: EmailSettingsServiceAPI = resolve()
    ) {
        self.kycClient = kycClient
        self.emailService = emailService
    }
    
    public func checkEmailVerificationStatus() -> AnyPublisher<EmailVerificationStatus, EmailVerificationCheckError> {
        kycClient.fetchUser()
            .map { $0.email.verified ? .verified : .unverified }
            .mapError(EmailVerificationCheckError.nabuError)
            .eraseToAnyPublisher()
    }
    
    public func sendVerificationEmail(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        // NOTE: our backend doesn't have a specific "re-send verification email" API. Attempting an update of the email address will trigger a re-send, though.
        updateEmailAddress(to: emailAddress)
    }
    
    public func updateEmailAddress(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        emailService.update(email: emailAddress)
            .mapToVoid()
            .mapError { error in
                switch error {
                case .credentialsError:
                    return .missingCredentials
                case .networkError(let error):
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
