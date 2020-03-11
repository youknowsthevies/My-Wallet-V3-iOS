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
        return simpleBuyFlowAvailabilityService.isSimpleBuyFlowAvailable
    }

    private let simpleBuyFlowAvailabilityService: SimpleBuyFlowAvailabilityServiceAPI

    init(serviceProvider: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider.default) {
        self.simpleBuyFlowAvailabilityService = serviceProvider.flowAvailability
    }
}
