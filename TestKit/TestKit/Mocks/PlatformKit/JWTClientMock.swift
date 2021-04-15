//
//  JWTClientMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

@testable import PlatformKit

final class JWTClientMock: JWTClientAPI {
    
    var expectedResult: Result<String, Error>!
    
    func requestJWT(guid: String, sharedKey: String) -> Single<String> {
        expectedResult.single
    }
}

final class JWTServiceMock: JWTServiceAPI {
    
    var expectedResult: Result<String, Error>!

    var token: Single<String> {
        expectedResult.single
    }
}
