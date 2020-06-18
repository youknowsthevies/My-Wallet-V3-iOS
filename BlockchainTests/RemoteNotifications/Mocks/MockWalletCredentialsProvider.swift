//
//  MockWalletCredentialsProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import PlatformKit
import RxSwift

class MockWalletCredentialsProvider: WalletCredentialsProviding {
    static var valid: WalletCredentialsProviding {
        MockWalletCredentialsProvider(
            legacyPassword: "blockchain"
        )
    }
    let legacyPassword: String?
    init(legacyPassword: String?) {
        self.legacyPassword = legacyPassword
    }
}

class GuidSharedKeyRepositoryAPIMock: GuidRepositoryAPI, SharedKeyRepositoryAPI {

    var expectedGuid: String? = "123-abc-456-def-789-ghi"
    var expectedSharedKey: String? = "0123456789"

    var guid: Single<String?> {
        .just(expectedGuid)
    }

    func set(guid: String) -> Completable {
        expectedGuid = guid
        return .empty()
    }

    var sharedKey: Single<String?> {
        .just(expectedSharedKey)
    }

    func set(sharedKey: String) -> Completable {
        expectedSharedKey = sharedKey
        return .empty()
    }
}
