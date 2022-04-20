// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import RxSwift

protocol SendEmailNotificationClientAPI {
    func postSendEmailNotificationTrigger(
        _ payload: SendEmailNotificationClient.Payload
    ) -> AnyPublisher<Void, NetworkError>
}

final class SendEmailNotificationClient: SendEmailNotificationClientAPI {

    struct Payload {
        let method = "trigger-sent-tx-email"
        let guid: String
        let sharedKey: String
        let currency: String
        let amount: String
        let network: String
        let txHash: String
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func postSendEmailNotificationTrigger(
        _ payload: Payload
    ) -> AnyPublisher<Void, NetworkError> {
        let request = requestBuilder.post(
            path: ["wallet"],
            parameters: [
                URLQueryItem(name: "method", value: payload.method),
                URLQueryItem(name: "guid", value: payload.guid),
                URLQueryItem(name: "sharedKey", value: payload.sharedKey),
                URLQueryItem(name: "currency", value: payload.currency),
                URLQueryItem(name: "amount", value: payload.amount),
                URLQueryItem(name: "network", value: payload.network),
                URLQueryItem(name: "txHash", value: payload.txHash)
            ]
        )
        return networkAdapter.perform(request: request!)
            .eraseToAnyPublisher()
    }
}
