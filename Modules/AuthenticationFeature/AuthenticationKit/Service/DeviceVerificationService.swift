// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

public enum DeviceVerificationServiceError: Error, Equatable {
    case missingSessionToken
    case recaptchaError(GoogleRecaptchaError)
    case networkError(NetworkError)

    public static func == (lhs: DeviceVerificationServiceError, rhs: DeviceVerificationServiceError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

/// `DeviceVerificationServiceAPI` is the interface the UI should use the authentication service APIs.
public protocol DeviceVerificationServiceAPI {

    /// Sends a verification email to the user's email address. Thie will trigger the send GUID reminder endpoint and user will receive a link to verify their device in their inbox if they have an account registered with the email
    /// - Parameters: emailAddress: The email address of the user
    /// - Returns: A combine `Publisher` that emits an EmptyNetworkResponse on success or NetworkError on failure
    func sendDeviceVerificationEmail(to emailAddress: String)
        -> AnyPublisher<Void, DeviceVerificationServiceError>

    /// Authorize the login to the associated email identified by the email code. The email code is received by decrypting the base64 information encrypted in the magic link from the device verification email
    /// - Parameters: emailCode: The email code for the authorization
    /// - Returns: A combine `Publisher` that emits an EmptyNetworkResponse on success or NetworkError on failure
    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError>

    /// Decodes the base64 string component from the deeplink
    /// - Parameters: deeplink: The url link received
    /// - Returns: A combine `Publisher` that emits an WalletInfo struct on success or WalletInfoError on failure
    func extractWalletInfoFromDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError>
}

public final class DeviceVerificationService: DeviceVerificationServiceAPI {

    // MARK: - Properties

    private let deviceVerificationRepository: DeviceVerificationRepositoryAPI
    private let sessionTokenRepository: SessionTokenRepositoryAPI
    private let recaptchaService: GoogleRecaptchaServiceAPI

    // MARK: - Setup

    public init(
        deviceVerificationRepository: DeviceVerificationRepositoryAPI = resolve(),
        sessionTokenRepository: SessionTokenRepositoryAPI = resolve(),
        recaptchaService: GoogleRecaptchaServiceAPI = resolve()
    ) {
        self.deviceVerificationRepository = deviceVerificationRepository
        self.sessionTokenRepository = sessionTokenRepository
        self.recaptchaService = recaptchaService
    }

    // MARK: - AuthenticationServiceAPI

    public func sendDeviceVerificationEmail(
        to emailAddress: String
    ) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        recaptchaService
            .verifyForLogin()
            .mapError(DeviceVerificationServiceError.recaptchaError)
            .flatMap { [deviceVerificationRepository] captcha -> AnyPublisher<Void, DeviceVerificationServiceError> in
                deviceVerificationRepository
                    .sendDeviceVerificationEmail(to: emailAddress, captcha: captcha)
            }
            .eraseToAnyPublisher()
    }

    public func authorizeLogin(emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        sessionTokenRepository
            .sessionTokenPublisher
            .setFailureType(to: DeviceVerificationServiceError.self)
            .flatMap { token -> AnyPublisher<String, DeviceVerificationServiceError> in
                guard let sessionToken = token else {
                    return .failure(.missingSessionToken)
                }
                return .just(sessionToken)
            }
            .flatMap { [deviceVerificationRepository] sessionToken -> AnyPublisher<Void, DeviceVerificationServiceError> in
                deviceVerificationRepository
                    .authorizeLogin(sessionToken: sessionToken, emailCode: emailCode)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func extractWalletInfoFromDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError> {
        Deferred {
            Future { promise in
                guard let base64LastPath = deeplink.absoluteString.components(separatedBy: "/").last?.paddedBase64,
                      let jsonData = Data(base64Encoded: base64LastPath, options: .ignoreUnknownCharacters)
                else {
                    promise(.failure(.failToDecodeBase64Component))
                    return
                }
                do {
                    let walletInfo = try JSONDecoder().decode(WalletInfo.self, from: jsonData)
                    promise(.success(walletInfo))
                } catch {
                    promise(.failure(.failToDecodeToWalletInfo(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
