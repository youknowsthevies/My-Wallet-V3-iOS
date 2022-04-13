// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Bundle {
    fileprivate class BundleFinder {}

    static var cardIssuing: Bundle {
        Bundle.find("FeatureCardIssuing_FeatureCardIssuingUI.bundle", in: BundleFinder.self)
    }
}
