//
//  NetworkCommunicatorMock.swift
//  BlockchainTests
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import NetworkKit
import ToolKit
import Combine

enum CommunicatorMockError: Error {
    case unknown
}

final class NetworkCommunicatorMock: NetworkCommunicatorAPI {
    
    func dataTaskPublisher(for request: NetworkRequest) -> AnyPublisher<ServerResponse, NetworkCommunicatorError> {
        unimplemented()
    }
}
