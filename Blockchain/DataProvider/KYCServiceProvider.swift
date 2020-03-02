//
//  KYCServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension KYCServiceProvider {
    static let `default`: KYCServiceProviderAPI = KYCServiceProvider(
        authenticationService: NabuAuthenticationService.shared
    )
}
