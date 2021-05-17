// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

class MockFeatureConfigurator: FeatureConfiguring {

    private let isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func configuration(for feature: AppFeature) -> AppFeatureConfiguration {
        AppFeatureConfiguration(isEnabled: isEnabled)
    }
}
