// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError
import RxSwift
import WalletPayloadKit

public enum EmailSettingsServiceError: Error {
    case credentialsError(MissingCredentialsError)
    case networkError(NetworkError)
    case unknown(Error)
}

public protocol EmailSettingsServiceAPI: AnyObject {

    /// A `Single` that streams
    var email: Single<String> { get }

    /// An `AnyPublisher` that streams the users email
    var emailPublisher: AnyPublisher<String, EmailSettingsServiceError> { get }

    /// Updates the email associated with the wallet
    /// - Parameter email: The new email address
    /// - Parameter context: The context in which the request has happened
    /// - Returns: A `Completable`
    func update(email: String, context: FlowContext?) -> Completable

    func update(email: String) -> AnyPublisher<String, EmailSettingsServiceError>
}
