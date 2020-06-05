//
//  SimpleBuyRouter+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import BuySellKit
import BuySellUIKit

extension SimpleBuyRouter {
    
    convenience init(stateService: SimpleBuyStateServiceAPI) {
        self.init(
            serviceProvider: SimpleBuyServiceProvider.default,
            cardServiceProvider: CardServiceProvider.default,
            userInformationProvider: UserInformationServiceProvider.default,
            stateService: stateService,
            kycServiceProvider: KYCServiceProvider.default,
            recordingProvider: RecordingProvider.default,
            topMostViewControllerProvider: UIApplication.shared,
            kycRouter: KYCCoordinator.shared,
            exchangeProvider: DataProvider.default.exchange
        )
    }
}
