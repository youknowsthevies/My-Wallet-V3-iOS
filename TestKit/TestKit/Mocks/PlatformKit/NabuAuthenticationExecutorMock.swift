//
//  NabuAuthenticationExecutorMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import NetworkKit
import ToolKit

@testable import PlatformKit

final class NabuAuthenticationExecutorMock: NabuAuthenticationExecutorAPI {
    
    func authenticate(
        _ networkResponsePublisher: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError> {
        unimplemented()
    }
}
