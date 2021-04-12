//
//  StellarWalletOptionsBridgeAPI.swift
//  StellarKit
//
//  Created by Paulo on 10/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

protocol StellarWalletOptionsBridgeAPI: class {
    var stellarConfigurationDomain: Single<String?> { get }
}

class StellarWalletOptionsService: StellarWalletOptionsBridgeAPI {
    private let walletOptionsService: WalletOptionsAPI

    init(walletOptions: WalletOptionsAPI = resolve()) {
        self.walletOptionsService = walletOptions
    }

    var stellarConfigurationDomain: Single<String?> {
        walletOptionsService
            .walletOptions
            .map(\.domains?.stellarHorizon)
    }
}
