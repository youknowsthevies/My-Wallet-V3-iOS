// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

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
