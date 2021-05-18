// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit
import PlatformKit

class APIClient: EventSendingAPI {

    private enum Path {
        static let transactions = ["events", "publish"]
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI
    private let tokenProvider: TokenProviding

    // MARK: - Setup

    init(networkAdapter: NetworkAdapterAPI = resolve(),
         requestBuilder: RequestBuilder = resolve(),
         tokenProvider: TokenProviding = resolve()) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.tokenProvider = tokenProvider
    }

    func publish(events: EventsWrapper) -> AnyPublisher<Void, NetworkError> {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        guard let body = try? jsonEncoder.encode(events) else {
            fatalError("Error encoding analytics event body.")
        }
        return tokenProvider.token
            .compactMap { [requestBuilder] in
                var headers = HTTPHeaders()
                if let token = $0 {
                    headers[HttpHeaderField.authorization] = "Bearer \(token)"
                }
                return requestBuilder.post(path: Path.transactions, body: body, headers: headers)
            }
            .setFailureType(to: NetworkError.self)
            .flatMap { [networkAdapter] request in
                networkAdapter.performOptional(request: request)
            }
            .eraseToAnyPublisher()
    }
}
