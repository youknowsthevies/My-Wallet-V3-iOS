//
//  SimpleBuyKYCPendingViewModel.swift
//  Blockchain
//
//  Created by Paulo on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit
import ToolKit

enum SimpleBuyKYCPendingVerificationState {
    case loading
    case pending
    case manualReview
    case ineligible
    case completed
}

extension SimpleBuyKYCPendingVerificationState {
    var analyticsEvent: AnalyticsEvents.SimpleBuy {
        switch self {
        case .loading, .completed:
            return .sbKycVerifying
        case .pending:
            return .sbKycPending
        case .manualReview:
            return .sbKycManualReview
        case .ineligible:
            return .sbPostKycNotEligible
        }
    }
}

struct SimpleBuyKYCPendingViewModel {
    enum Image: String {
        case error = "error-triagle-medium"
        case clock = "icon_clock_inverted"
        case region = "icon-error-region"
        var image: UIImage! {
            return UIImage(named: rawValue)
        }
    }

    enum Asset {
        case loading
        case image(Image)
    }

    let asset: Asset
    let title: NSAttributedString
    let subtitle: NSAttributedString
    let button: ButtonViewModel?
    static private func title(_ string: String) -> NSAttributedString {
        return NSAttributedString(
            string,
            font: .mainRegular(20),
            color: .titleText
        )
    }
    static private func subtitle(_ string: String) -> NSAttributedString {
        return NSAttributedString(
            string,
            font: .mainRegular(14),
            color: .descriptionText
        )
    }
    init(asset: Asset, title: String, subtitle: String, button: ButtonViewModel? = nil) {
        self.asset = asset
        self.title = SimpleBuyKYCPendingViewModel.title(title)
        self.subtitle = SimpleBuyKYCPendingViewModel.subtitle(subtitle)
        self.button = button
    }
}
