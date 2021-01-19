//
//  WalletServiceMock.swift
//  PlatformKitTests
//
//  Created by Chris Arriola on 6/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class WalletServiceMock: WalletOptionsAPI {

    var underlyingServerUnderMaintenanceMessage: String?
    var serverUnderMaintenanceMessage: Single<String?> {
        .just(underlyingServerUnderMaintenanceMessage)
    }

    var underlyingWalletOptions: WalletOptions = .empty
    var walletOptions: Single<WalletOptions> {
        .just(underlyingWalletOptions)
    }
}

extension WalletOptions {
    static var empty: WalletOptions {
        WalletOptions(json: ["maintenance": false])
    }
}
