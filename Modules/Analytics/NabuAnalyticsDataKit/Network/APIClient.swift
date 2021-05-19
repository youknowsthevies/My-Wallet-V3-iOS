// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

protocol EventSendingAPI {

    func publish<Events: Encodable>(
        events: Events,
        token: String?
    ) -> AnyPublisher<Void, NetworkError>
}

final class APIClient: EventSendingAPI {

    // MARK: - Types

    private enum Path {

        static let transactions = [ "events", "publish" ]
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI
    private let jsonEncoder: JSONEncoder

    // MARK: - Setup

    init(networkAdapter: NetworkAdapterAPI = resolve(),
         requestBuilder: RequestBuilder = resolve(),
         jsonEncoder: JSONEncoder = {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            return jsonEncoder
         }()) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.jsonEncoder = jsonEncoder
    }

    // MARK: - Methods

    func publish<Events: Encodable>(
        events: Events,
        token: String?
    ) -> AnyPublisher<Void, NetworkError> {
        var headers = HTTPHeaders()
        if let token = token {
            headers[HttpHeaderField.authorization] = "Bearer \(token)"
        }
        // swiftlint:disable:next force_try
        let body = try! jsonEncoder.encode(events)
        let request = requestBuilder.post(
            path: Path.transactions,
            body: body,
            headers: headers
        )!
        return networkAdapter.performOptional(request: request)
    }
}
