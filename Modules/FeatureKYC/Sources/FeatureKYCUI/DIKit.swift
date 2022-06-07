// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import ToolKit

extension DependencyContainer {

    // MARK: - Blockchain Module

    public static let featureKYCUI = module {

        single { KYCRouter() as KYCRouterAPI }

        factory { () -> FeatureKYCUI.Routing in
            let externalAppOpener: ExternalAppOpener = DIKit.resolve()
            return FeatureKYCUI.Router(
                analyticsRecorder: DIKit.resolve(),
                loadingViewPresenter: DIKit.resolve(),
                legacyRouter: DIKit.resolve(),
                kycService: DIKit.resolve(),
                emailVerificationService: DIKit.resolve(),
                openMailApp: externalAppOpener.openMailApp,
                openURL: externalAppOpener.open
            )
        }
    }
}
