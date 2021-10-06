// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let featureTour = Bundle.find("FeatureTour_FeatureTourUI.bundle", in: BundleFinder.self)
}
