// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public enum WalletPayloadServiceError: Error {

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

public protocol WalletPayloadServiceCombineAPI: AnyObject {

    /// Using the GUID and Session Token stored in the wallet repository, it sends a request to the wallet payload client and the response will include a required authenticator type (e.g., email/google authenticator) or errors depending on different scenario
    /// - Returns: A combine `Publisher` that emits an authenticator type on success or ServiceError on failure
    func requestUsingSessionTokenPublisher() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError>

    /// Using the GUID and Shared Key stored in the wallet repository, it sends an authentication request to the wallet paylod client and if authentication is successful if there are no errors returned (used for PIN decryption)
    /// - Returns: A combine `Publisher` that emits nothing or ServiceError on failure
    func requestUsingSharedKeyPublisher() -> AnyPublisher<Void, WalletPayloadServiceError>

    /// Handles the authentication request to be sent to the wallet payload client using GUID and shared key stored in the wallet repository
    /// - Parameters guid: guid retrieved from the wallet repository
    /// - Parameters: sharedkey shared key retrieved from the wallet repository
    /// - Returns: A combine `Publisher` that emits nothing or ServiceError if failure occurs
    func requestPublisher(guid: String, sharedKey: String) -> AnyPublisher<Void, WalletPayloadServiceError>
}

public protocol WalletPayloadServiceAPI: WalletPayloadServiceCombineAPI {
    func requestUsingSessionToken() -> Single<WalletAuthenticatorType>
    func requestUsingSharedKey() -> Completable
    func request(guid: String, sharedKey: String) -> Completable
}
