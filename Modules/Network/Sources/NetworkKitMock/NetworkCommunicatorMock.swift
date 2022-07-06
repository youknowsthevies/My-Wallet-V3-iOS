// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
@testable import NetworkKit
import ToolKit

enum CommunicatorMockError: Error {
    case unknown
}

final class NetworkCommunicatorMock: NetworkCommunicatorAPI {
    func dataTaskWebSocketPublisher(for request: NetworkRequest) -> AnyPublisher<ServerResponse, NetworkError> {
        unimplemented()
    }

    func dataTaskPublisher(for request: NetworkRequest) -> AnyPublisher<ServerResponse, NetworkError> {
        unimplemented()
    }
}
