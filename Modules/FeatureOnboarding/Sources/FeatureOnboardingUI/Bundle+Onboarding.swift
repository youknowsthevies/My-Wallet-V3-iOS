// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

extension Bundle {

    static var onboarding: Bundle {
        class BundleFinder {}
        return Bundle.find("FeatureOnboarding_FeatureOnboardingUI.bundle", in: BundleFinder.self)
    }
}
