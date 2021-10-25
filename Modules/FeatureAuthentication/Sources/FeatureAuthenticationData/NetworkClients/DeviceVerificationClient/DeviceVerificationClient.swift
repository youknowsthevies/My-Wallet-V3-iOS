// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import Foundation
import NetworkKit
import ToolKit

final class DeviceVerificationClient: DeviceVerificationClientAPI {

    // MARK: - Types

    private enum Path {
        static let wallet = ["wallet"]
        static let emailReminder = ["auth", "email-reminder"]
        static let pollWalletInfo = ["wallet", "poll-for-wallet-info"]
    }

    private enum Parameters {
        enum AuthorizeApprove {
            static let method = "method"
            static let comfirmApproval = "confirm_approval"
            static let token = "token"
        }
    }

    private enum HeaderKey: String {
        case cookie
    }

    // MARK: - Properties

    private let walletRequestBuilder: RequestBuilder
    private let defaultRequestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        walletRequestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet),
        defaultRequestBuilder: RequestBuilder = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.walletRequestBuilder = walletRequestBuilder
        self.defaultRequestBuilder = defaultRequestBuilder
    }

    // MARK: - Methods

    func sendGuidReminder(
        sessionToken: String,
        emailAddress: String,
        captcha: String
    ) -> AnyPublisher<Void, NetworkError> {
        struct Payload: Encodable {
            let email: String
            let captcha: String
            let siteKey: String
            let product: String
        }
        let headers = [HttpHeaderField.authorization: "Bearer \(sessionToken)"]
        let payload = Payload(
            email: emailAddress,
            captcha: captcha,
            siteKey: AuthenticationKeys.googleRecaptchaSiteKey,
            product: "wallet"
        )
        let request = defaultRequestBuilder.post(
            path: Path.emailReminder,
            body: try? payload.encode(),
            headers: headers
        )!
        return networkAdapter.perform(request: request)
    }

    func authorizeApprove(
        sessionToken: String,
        emailCode: String
    ) -> AnyPublisher<AuthorizeApproveResponse, NetworkError> {
        let headers = [HeaderKey.cookie.rawValue: "SID=\(sessionToken)"]
        let parameters = [
            URLQueryItem(
                name: Parameters.AuthorizeApprove.method,
                value: "authorize-approve"
            ),
            URLQueryItem(
                name: Parameters.AuthorizeApprove.comfirmApproval,
                value: "true"
            ),
            URLQueryItem(
                name: Parameters.AuthorizeApprove.token,
                value: emailCode
            )
        ]
        let data = RequestBuilder.body(from: parameters)
        let request = walletRequestBuilder.post(
            path: Path.wallet,
            body: data,
            headers: headers,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }

    func pollForWalletInfo(
        sessionToken: String
    ) -> AnyPublisher<WalletInfo?, Never> {
        let headers = [HttpHeaderField.authorization: "Bearer \(sessionToken)"]
        let request = walletRequestBuilder.get(
            path: Path.pollWalletInfo,
            headers: headers
        )!
        return networkAdapter.perform(request: request)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
