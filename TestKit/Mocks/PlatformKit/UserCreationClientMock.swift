//
//  UserCreationClientMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//


import RxSwift

@testable import PlatformKit

final class UserCreationClientMock: UserCreationClientAPI {
    
    var expectedResult: Result<NabuOfflineTokenResponse, Error>!
    
    func createUser(for jwtToken: String) -> Single<NabuOfflineTokenResponse> {
        expectedResult.single
    }
}
