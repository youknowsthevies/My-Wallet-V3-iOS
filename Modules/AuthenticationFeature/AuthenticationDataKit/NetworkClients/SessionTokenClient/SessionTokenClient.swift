// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import DIKit
import NetworkKit
import RxSwift

/// A session token client implementation
public final class SessionTokenClient: SessionTokenClientAPI {

    private struct Response: Decodable {
        let token: String?
    }

    // MARK: - Properties

    /// Requests a session token for the wallet, if not available already
    public var token: Single<String> {
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            contentType: .json
        )
        return networkAdapter
            .perform(request: request, responseType: Response.self)
            .map(\.token)
            .map { token -> String in
                guard let token = token else { throw SessionTokenServiceError.missingSessionToken }
                return token
            }
    }

    private let url = URL(string: BlockchainAPI.shared.walletSession)!
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve())
    {
        self.networkAdapter = networkAdapter
    }
}

// MARK: - Combine

extension SessionTokenClient {

    public var tokenPublisher: AnyPublisher<String?, NetworkError> {
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            contentType: .json
        )
        return networkAdapter
            .perform(request: request, responseType: Response.self)
            .map(\.token)
            .eraseToAnyPublisher()
    }
}
