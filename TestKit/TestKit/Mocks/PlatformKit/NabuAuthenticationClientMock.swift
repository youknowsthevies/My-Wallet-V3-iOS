//
//  NabuAuthenticationClientMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import NetworkKit

@testable import PlatformKit

final class NabuAuthenticationClientMock: NabuAuthenticationClientAPI {
    
    var expectedSessionTokenResult: Result<NabuSessionTokenResponse, NetworkCommunicatorError>!
    
    var expectedRecoverUserResult: Result<Void, NetworkCommunicatorError>!
    
    func sessionTokenPublisher(
        for guid: String,
        userToken: String,
        userIdentifier: String,
        deviceId: String,
        email: String
    ) -> AnyPublisher<NabuSessionTokenResponse, NetworkCommunicatorError> {
        expectedSessionTokenResult.publisher.eraseToAnyPublisher()
    }
    
    func recoverUserPublisher(
        offlineToken: NabuOfflineTokenResponse,
        jwt: String
    ) -> AnyPublisher<Void, NetworkCommunicatorError> {
        expectedRecoverUserResult.publisher.eraseToAnyPublisher()
    }
}
