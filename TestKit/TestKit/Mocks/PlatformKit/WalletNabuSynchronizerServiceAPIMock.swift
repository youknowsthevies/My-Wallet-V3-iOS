//
//  WalletNabuSynchronizerServiceAPIMock.swift
//  StellarKitTests
//
//  Created by Paulo on 07/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class WalletNabuSynchronizerServiceAPIMock: WalletNabuSynchronizerServiceAPI {

    func sync() -> Completable {
        .empty()
    }
}
