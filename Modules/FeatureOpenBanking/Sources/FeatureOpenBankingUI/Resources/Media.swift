// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIComponentsKit

private class BundleFinder {}
extension Bundle {
    static let openBanking = Bundle.find("FeatureOpenBanking_FeatureOpenBankingUI.bundle", in: BundleFinder.self)
}

extension Media {
    static let blockchainLogo: Media = .image(named: "blockchain")
    static let bankIcon: Media = .image(named: "bank")
    static let success: Media = .image(named: "success")
    static let error: Media = .image(named: "warning")
}
