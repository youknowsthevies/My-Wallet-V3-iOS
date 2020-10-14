//
//  KYCVerifyEmailRouter.swift
//  Blockchain
//
//  Created by kevinwu on 2/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import KYCKit
import PlatformKit
import PlatformUIKit
import ToolKit

/// Router for handling the KYC verify email flow
public final class KYCDeepLinkRouter: DeepLinkRouting {

    private let kycSettings: KYCSettingsAPI
    private let kycRouter: KYCRouterAPI

    public init(
        kycSettings: KYCSettingsAPI = resolve(),
        kycRouter: KYCRouterAPI = resolve()
    ) {
        self.kycSettings = kycSettings
        self.kycRouter = kycRouter
    }

    public func routeIfNeeded() -> Bool {
        // Only route if the user actually tapped on the verify email link
        guard kycSettings.didTapOnKycDeepLink else {
            return false
        }
        kycSettings.didTapOnKycDeepLink = false

        // Only route if the user was completing kyc
        guard kycSettings.isCompletingKyc else {
            return false
        }

        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            return false
        }
        kycRouter.start(from: viewController, tier: .tier1, parentFlow: .none)
        return true
    }
}
