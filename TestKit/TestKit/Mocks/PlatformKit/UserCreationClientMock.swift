//
//  UserCreationClientMock.swift
//  TransactionUIKitTests
//
//  Created by Jack Pooley on 09/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import NetworkKit
import ToolKit

@testable import PlatformKit

final class UserCreationClientMock: UserCreationClientAPI {
    
    var expectedResult: Result<NabuOfflineTokenResponse, NetworkCommunicatorError>!
    
    func createUser(
        for jwtToken: String
    ) -> AnyPublisher<NabuOfflineTokenResponse, NetworkCommunicatorError> {
        expectedResult.publisher
    }
}
