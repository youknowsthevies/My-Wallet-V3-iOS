// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkError

typealias FetchMetadataEntry = (String) -> AnyPublisher<MetadataPayload, NetworkError>
typealias PutMetadataEntry = (String, MetadataBody) -> AnyPublisher<Void, NetworkError>

public protocol MetadataRepositoryAPI {

    func fetch(at address: String) -> AnyPublisher<MetadataPayload, NetworkError>

    func put(
        at address: String,
        with body: MetadataBody
    ) -> AnyPublisher<Void, NetworkError>
}
