// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

public protocol WalletPayloadServiceAPI: AnyObject {

    /// Using the GUID and Session Token stored in the wallet repository, it sends a request to the wallet payload client and the response will include a required authenticator type (e.g., email/google authenticator) or errors depending on different scenario
    /// - Returns: A combine `Publisher` that emits an authenticator type on success or ServiceError on failure
    func requestUsingSessionToken() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError>

    /// Using the GUID and Shared Key stored in the wallet repository, it sends an authentication request to the wallet paylod client and if authentication is successful if there are no errors returned (used for PIN decryption)
    /// - Returns: A combine `Publisher` that emits nothing or ServiceError on failure
    func requestUsingSharedKey() -> AnyPublisher<Void, WalletPayloadServiceError>

    /// Handles the authentication request to be sent to the wallet payload client using GUID and shared key stored in the wallet repository
    /// - Parameters guid: guid retrieved from the wallet repository
    /// - Parameters: sharedkey shared key retrieved from the wallet repository
    /// - Returns: A combine `Publisher` that emits nothing or ServiceError if failure occurs
    func request(guid: String, sharedKey: String) -> AnyPublisher<Void, WalletPayloadServiceError>

    /// Handles the authentication request to be sent to the wallet payload client using GUID and session token in the wallet repository
    /// - Parameters guid: guid retrieved from the wallet repository
    /// - Parameters: sessionToken shared token retrieved from the wallet repository
    /// - Returns: A combine `Publisher` that emits nothing or ServiceError if failure occurs
    func request(
        guid: String,
        sessionToken: String
    ) -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError>
}
