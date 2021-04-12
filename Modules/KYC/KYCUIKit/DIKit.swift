//
//  DIKit.swift
//  KYCUIKit
//
//  Created by Paulo on 06/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformUIKit

extension DependencyContainer {

    // MARK: - Blockchain Module

    public static let kycUIKit = module {
        single { KYCCoordinator() as KYCRouterAPI }

        factory { KYCTiersPageModelFactory() as KYCTiersPageModelFactoryAPI }
    }
}
