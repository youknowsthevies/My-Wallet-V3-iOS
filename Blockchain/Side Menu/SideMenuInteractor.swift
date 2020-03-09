//
//  SideMenuInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class SideMenuInteractor {

    var isSimpleBuyFlowAvailable: Observable<Bool> {
        return service.isSimpleBuyFlowAvailable
    }

    private let service: SimpleBuyFlowAvailabilityServiceAPI

    convenience init(walletManager: WalletManager = WalletManager.shared,
                     fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
                     supportedPairsService: SimpleBuySupportedPairsServiceAPI = SimpleBuyServiceProvider.default.supportedPairs) {
        let service = SimpleBuyFlowAvailabilityService(coinifyAccountRepository: CoinifyAccountRepository(bridge: walletManager.wallet),
                                                       fiatCurrencyService: fiatCurrencyService,
                                                       supportedPairsService: supportedPairsService)
        self.init(service: service)
    }

    init(service: SimpleBuyFlowAvailabilityServiceAPI) {
        self.service = service
    }
}
