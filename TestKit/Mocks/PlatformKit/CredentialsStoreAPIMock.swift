//
//  CredentialsStoreAPIMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 07/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class CredentialsStoreAPIMock: CredentialsStoreAPI {

    func backup(pinDecryptionKey: String) -> Completable {
        .empty()
    }

    var expectedPinData: CredentialsPinData?
    func pinData() -> CredentialsPinData? {
        expectedPinData
    }

    var expectedWalletData: Single<CredentialsWalletData> = .error(NSError(domain: "Error", code: 1, userInfo: nil))
    func walletData(pinDecryptionKey: String) -> Single<CredentialsWalletData> {
        expectedWalletData
    }

    func synchronize() {

    }

    func erase() {

    }
}
