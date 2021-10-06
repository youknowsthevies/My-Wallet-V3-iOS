// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let featureKYCUI = Bundle.find("FeatureKYC_FeatureKYCUI.bundle", in: BundleFinder.self)
}
