//
//  NabuAuthenticationServiceMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class NabuAuthenticationServiceMock: NabuAuthenticationServiceAPI {

    static let token = NabuSessionTokenResponse(
        identifier: "identifier",
        userId: "userId",
        token: "token",
        isActive: true,
        expiresAt: Date.distantFuture
    )

    var underlyingSessionToken: NabuSessionTokenResponse = NabuAuthenticationServiceMock.token
    func getSessionToken(requestNewToken: Bool) -> Single<NabuSessionTokenResponse> {
        return .just(underlyingSessionToken)
    }

    func getSessionToken() -> Single<NabuSessionTokenResponse> {
        return .just(underlyingSessionToken)
    }

    func updateWalletInfo() -> Completable {
        return .empty()
    }
}

