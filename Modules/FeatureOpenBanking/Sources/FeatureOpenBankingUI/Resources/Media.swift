// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIComponentsKit

private class BundleFinder {}
extension Bundle {
    public static let openBanking = Bundle.find(
        "FeatureOpenBanking_FeatureOpenBankingUI.bundle",
        "Blockchain_FeatureOpenBankingUI.bundle",
        in: BundleFinder.self
    )
}

extension Media {
    static let inherited: Media = .empty
    static let blockchainLogo: Media = .image(named: "blockchain", in: .openBanking)
    static let bankIcon: Media = .image(named: "bank", in: .openBanking)
    static let success: Media = .image(named: "success", in: .openBanking)
    static let error: Media = .image(named: "warning", in: .openBanking)
    static let clock: Media = .image(named: "clock", in: .openBanking)
    static let cross: Media = .image(named: "cross", in: .openBanking)
}
