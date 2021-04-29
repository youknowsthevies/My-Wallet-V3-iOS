// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import KYCKit
import PlatformKit
import PlatformUIKit

/// Router for handling the KYC document resubmission flow
public final class KYCResubmitIdentityRouter: DeepLinkRouting {

    private let settings: KYCSettingsAPI
    private let kycRouter: KYCRouterAPI

    public init(
        settings: KYCSettingsAPI = resolve(),
        kycRouter: KYCRouterAPI = resolve()
    ) {
        self.settings = settings
        self.kycRouter = kycRouter
    }

    public func routeIfNeeded() -> Bool {
        // Only route if the user actually tapped on the resubmission link
        guard settings.didTapOnDocumentResubmissionDeepLink else {
            return false
        }

        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            return false
        }
        kycRouter.start(from: viewController, tier: .tier2, parentFlow: .none)
        return true
    }
}
