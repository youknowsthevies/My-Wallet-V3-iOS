//
//  DIKit.swift
//  KYCKit
//
//  Created by Paulo on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - KYCKit Module

    public static var kycKit = module {

        single { KYCSettings() as KYCSettingsAPI }
    }
}
