//
//  JWTClientMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import RxSwift

@testable import PlatformKit

final class JWTClientMock: JWTClientAPI {
    
    var expectedResult: Result<String, JWTClient.ClientError>!
    
    func requestJWT(guid: String, sharedKey: String) -> AnyPublisher<String, JWTClient.ClientError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}

final class JWTServiceMock: JWTServiceAPI {
    
    var expectedResult: Result<String, JWTServiceError>!
    
    var token: AnyPublisher<String, JWTServiceError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}
