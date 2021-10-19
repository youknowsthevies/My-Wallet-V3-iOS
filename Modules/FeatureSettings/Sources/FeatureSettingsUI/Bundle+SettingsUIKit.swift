// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let featureSettingsUI = Bundle.find("FeatureSettings_FeatureSettingsUI.bundle", in: BundleFinder.self)
}
