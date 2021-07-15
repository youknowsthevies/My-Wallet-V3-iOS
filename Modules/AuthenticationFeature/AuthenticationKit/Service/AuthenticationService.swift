// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

public enum AuthenticationServiceError: Error {
    case missingSessionToken
    case networkError(NetworkError)
}

/// `AuthenticationServiceAPI` is the interface the UI should use the authentication service APIs.
public protocol AuthenticationServiceAPI {

    /// Sends a verification email to the user's email address. Thie will trigger the send GUID reminder endpoint and user will receive a link to verify their device in their inbox if they have an account registered with the email
    /// - Parameters: emailAddress: The email address of the user
    /// - Parameters: captcha: The captcha token returned from reCaptcha Service
    /// - Returns: A combine `Publisher` that emits an EmptyNetworkResponse on success or NetworkError on failure
    func sendDeviceVerificationEmail(
        to emailAddress: String,
        captcha: String)
    -> AnyPublisher<Void, AuthenticationServiceError>

    /// Authorize the login to the associated email identified by the email code. The email code is received by decrypting the base64 information encrypted in the magic link from the device verification email
    /// - Parameters: emailCode: The email code for the authorization
    /// - Returns: A combine `Publisher` that emits an EmptyNetworkResponse on success or NetworkError on failure
    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, AuthenticationServiceError>

    /// Decodes the base64 string component from the deeplink
    /// - Parameters: deeplink: The url link received
    /// - Returns: A combine `Publisher` that emits an WalletInfo struct on success or WalletInfoError on failure
    func extractWalletInfoFromDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError>
}

public final class AuthenticationService: AuthenticationServiceAPI {

    // MARK: - Properties

    private let authenticationRepository: AuthenticationRepositoryAPI
    private let sessionTokenRepository: SessionTokenRepositoryAPI

    // MARK: - Setup

    public init(authenticationRepository: AuthenticationRepositoryAPI = resolve(),
                sessionTokenRepository: SessionTokenRepositoryAPI) {
        self.authenticationRepository = authenticationRepository
        self.sessionTokenRepository = sessionTokenRepository
    }

    // MARK: - AuthenticationServiceAPI

    public func sendDeviceVerificationEmail(
        to emailAddress: String,
        captcha: String
    ) -> AnyPublisher<Void, AuthenticationServiceError> {
        authenticationRepository
            .sendDeviceVerificationEmail(to: emailAddress, captcha: captcha)
            .eraseToAnyPublisher()
    }

    public func authorizeLogin(emailCode: String) -> AnyPublisher<Void, AuthenticationServiceError> {
        sessionTokenRepository
            .sessionTokenPublisher
            .setFailureType(to: AuthenticationServiceError.self)
            .flatMap { token -> AnyPublisher<String, AuthenticationServiceError> in
                guard let sessionToken = token else {
                    return .failure(.missingSessionToken)
                }
                return .just(sessionToken)
            }
            .flatMap { [authenticationRepository] sessionToken -> AnyPublisher<Void, AuthenticationServiceError> in
                authenticationRepository
                    .authorizeLogin(sessionToken: sessionToken, emailCode: emailCode)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func extractWalletInfoFromDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError> {
        Deferred {
            Future { promise in
                guard let base64LastPath = deeplink.absoluteString.components(separatedBy: "/").last?.paddedBase64,
                      let jsonData = Data(base64Encoded: base64LastPath, options: .ignoreUnknownCharacters) else {
                    promise(.failure(.failToDecodeBase64Component))
                    return
                }
                do {
                    let walletInfo = try JSONDecoder().decode(WalletInfo.self, from: jsonData)
                    promise(.success(walletInfo))
                } catch let error {
                    promise(.failure(.failToDecodeToWalletInfo(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
