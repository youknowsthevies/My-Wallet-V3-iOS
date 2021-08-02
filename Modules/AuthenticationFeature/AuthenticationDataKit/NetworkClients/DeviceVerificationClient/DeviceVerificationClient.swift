// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import DIKit
import NetworkKit
import ToolKit

final class DeviceVerificationClient: DeviceVerificationClientAPI {

    // MARK: - Types

    private enum Path {
        static let wallet = ["wallet"]
    }

    private enum Parameters {
        enum SendGuidReminder {
            static let method = "method"
            static let email = "email"
            static let captcha = "captcha"
            static let siteKey = "siteKey"
        }

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

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - Methods

    func sendGuidReminder(emailAddress: String, captcha: String) -> AnyPublisher<Void, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameters.SendGuidReminder.method,
                value: "send-guid-reminder"
            ),
            URLQueryItem(
                name: Parameters.SendGuidReminder.email,
                value: emailAddress
            ),
            URLQueryItem(
                name: Parameters.SendGuidReminder.captcha,
                value: captcha
            ),
            URLQueryItem(
                name: Parameters.SendGuidReminder.siteKey,
                value: AuthenticationKeys.googleRecaptchaSiteKey
            )
        ]
        // TODO: Add this logic in a separate function later
        var components = URLComponents()
        components.queryItems = parameters
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let data = components.percentEncodedQuery?.data(using: .utf8)

        let request = requestBuilder.post(
            path: Path.wallet,
            body: data,
            contentType: .formUrlEncoded
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
        // TODO: Add this logic in a separate function later
        var components = URLComponents()
        components.queryItems = parameters
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let data = components.percentEncodedQuery?.data(using: .utf8)

        let request = requestBuilder.post(
            path: Path.wallet,
            body: data,
            headers: headers,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }
}
