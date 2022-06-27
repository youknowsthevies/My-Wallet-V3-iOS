import Combine
import Foundation
import NetworkKit

internal struct WalletDeactivationRequest {
    private let method: String = "deactivate-wallet"
    private let guid: String
    private let sharedKey: String
    private let email: String

    private enum Parameters {
        static let method = "method"
        static let guid = "guid"
        static let sharedKey = "sharedKey"
        static let email = "email"
    }

    public init(
        guid: String,
        sharedKey: String,
        email: String
    ) {
        self.guid = guid
        self.sharedKey = sharedKey
        self.email = email
    }

    public var parameters: [URLQueryItem] {
        [
            URLQueryItem(
                name: Parameters.method,
                value: "deactivate-wallet"
            ),
            URLQueryItem(
                name: Parameters.guid,
                value: guid
            ),
            URLQueryItem(
                name: Parameters.sharedKey,
                value: sharedKey
            ),
            URLQueryItem(
                name: Parameters.email,
                value: email
            )
        ]
    }
}
