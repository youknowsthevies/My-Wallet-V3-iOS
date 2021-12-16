// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import NetworkError
import ToolKit

final class MetadataRepository: MetadataRepositoryAPI {

    // MARK: - Private properties

    private let client: MetadataClientAPI

    // MARK: - Setup

    init(client: MetadataClientAPI) {
        self.client = client
    }

    // MARK: - MetadataRepositoryAPI

    func fetch(
        at address: String
    ) -> AnyPublisher<MetadataPayload, NetworkError> {
        client.get(address: address)
            .map(MetadataPayload.init(from:))
            .eraseToAnyPublisher()
    }

    func put(
        at address: String,
        with body: MetadataBody
    ) -> AnyPublisher<Void, NetworkError> {
        client.put(payload: body, at: address)
    }
}
