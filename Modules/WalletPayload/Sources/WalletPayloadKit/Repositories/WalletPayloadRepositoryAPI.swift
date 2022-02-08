// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum WalletPayloadIdentifier {

    /// Session token (e.g pairing)
    case sessionToken(String)

    /// Shared key (e.g PIN auth)
    case sharedKey(String)
}

public enum WalletPayloadServiceError: Error, Equatable {

    /// The payload returned from the backend is empty
    case missingPayload

    /// Credentials are missing
    case missingCredentials(MissingCredentialsError)

    /// Email Authorization is required
    case emailAuthorizationRequired

    /// Unsupported 2FA Type
    case unsupported2FAType

    /// The account is locked due to many failed authentication
    case accountLocked

    /// Error with a custom message
    case message(String)

    /// Unknown error
    case unknown
}

public protocol WalletPayloadRepositoryAPI {

    func payload(
        guid: String,
        identifier: WalletPayloadIdentifier
    ) -> AnyPublisher<WalletPayload, WalletPayloadServiceError>
}
