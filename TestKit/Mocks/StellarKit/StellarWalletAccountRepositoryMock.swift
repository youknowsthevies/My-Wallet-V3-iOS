//
//  StellarWalletAccountRepositoryMock.swift
//  Blockchain
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift
import StellarKit

class StellarWalletAccountRepositoryMock: StellarWalletAccountRepositoryAPI {
    func initializeMetadataMaybe() -> Maybe<StellarWalletAccount> {
        Maybe.empty()
    }

    var defaultAccount: StellarWalletAccount?

    func loadKeyPair() -> Maybe<StellarKeyPair> {
        Maybe.empty()
    }
}
