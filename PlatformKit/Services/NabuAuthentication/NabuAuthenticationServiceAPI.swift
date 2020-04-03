//
//  NabuAuthenticationServiceAPI.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

// TODO: Create a service and client out of this - separate wallet update from the
public protocol NabuAuthenticationServiceAPI: class {
    var fetchValue: Single<NabuSessionTokenResponse> { get }
    var value: Single<NabuSessionTokenResponse> { get }
    var tokenString: Single<String> { get }
    func updateWalletInfo() -> Completable
}

extension NabuAuthenticationServiceAPI {
    public var tokenString: Single<String> {
        value.map { $0.token }
    }
}
