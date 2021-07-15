// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public enum EmailAuthorizationServiceError: Error {
    /// Session token is missing
    case missingSessionToken

    /// Instance of self was deallocated
    case unretainedSelf

    /// Authorization is already active
    case authorizationAlreadyActive

    /// Cancellation error
    case authorizationCancelled

    /// Guid Service Error
    case guidService(GuidServiceError)
}

public protocol EmailAuthorizationServiceAPI {
    var authorize: Completable { get }
    func cancel()

    func authorizeEmailPublisher() -> AnyPublisher<Void, EmailAuthorizationServiceError>
}
