//
//  SwapServiceProviderAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

final class SwapServiceProvider: SwapServiceProviderAPI {
    
    static let `default`: SwapServiceProviderAPI = SwapServiceProvider()
    
    // MARK: - Properties

    let activity: SwapActivityService
    
    init(authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         swapClient: SwapClientAPI = SwapClient(),
         fiatCurrencyProvider: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings) {
        activity = SwapActivityService(
            client: swapClient, authenticationService:
            authenticationService,
            fiatCurrencyProvider: fiatCurrencyProvider
        )
    }
}
