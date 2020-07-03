//
//  NabuAuthenticationClientMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

@testable import PlatformKit

final class NabuAuthenticationClientMock: NabuAuthenticationClientAPI {

    var expectedSessionTokenResult: Result<NabuSessionTokenResponse, Error>!
    var expectedRecoverUserResult: Result<Void, Error>!
    
    func sessionToken(for guid: String,
                      userToken: String,
                      userIdentifier: String,
                      deviceId: String,
                      email: String) -> Single<NabuSessionTokenResponse> {
        expectedSessionTokenResult.single
    }
    
    func recoverUser(offlineToken: NabuOfflineTokenResponse, jwt: String) -> Completable {
        expectedRecoverUserResult.single.asCompletable()
    }
}
