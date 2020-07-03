//
//  NabuServiceProvider.swift
//  Blockchain
//
//  Created by Daniel on 29/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension NabuServiceProvider {

    static let `default`: NabuServiceProviderAPI = NabuServiceProvider()

    convenience init() {
        self.init(
            jwtClient: JWTClient(),
            updateWalletInformationClient: UpdateWalletInformationClient(),
            walletRepository: WalletManager.shared.repository,
            settingsService: UserInformationServiceProvider.default.settings,
            deviceInfo: UIDevice.current
        )
    }
}
