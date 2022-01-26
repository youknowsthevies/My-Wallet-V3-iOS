// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

protocol PushNotificationsClientAPI {
    /// revoke the firebase registration token for remote notifications (2FA), it is expeceted to be used when forgetting wallet.
    func revokeToken(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError>
}

final class PushNotificationsClient: PushNotificationsClientAPI {

    // MARK: - Types

    private enum Path {
        static let wallet = ["wallet"]
    }

    private enum Parameters {
        enum RevokeFirebase {
            static let method = "method"
            static let guid = "guid"
            static let sharedKey = "sharedKey"
        }
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

    // MARK: - API

    func revokeToken(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameters.RevokeFirebase.method,
                value: "revoke-firebase"
            ),
            URLQueryItem(
                name: Parameters.RevokeFirebase.guid,
                value: guid
            ),
            URLQueryItem(
                name: Parameters.RevokeFirebase.sharedKey,
                value: sharedKey
            )
        ]
        let data = RequestBuilder.body(from: parameters)
        let request = requestBuilder.post(
            path: Path.wallet,
            body: data,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }
}
