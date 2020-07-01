//
//  KYCPendingVerificationState.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import ToolKit

enum KYCPendingVerificationState {
    case loading
    case pending
    case manualReview
    case ineligible
    case completed
}

extension KYCPendingVerificationState {
    var analyticsEvent: AnalyticsEvent {
        switch self {
        case .loading, .completed:
            return AnalyticsEvents.SimpleBuy.sbKycVerifying
        case .pending:
            return AnalyticsEvents.SimpleBuy.sbKycPending
        case .manualReview:
            return AnalyticsEvents.SimpleBuy.sbKycManualReview
        case .ineligible:
            return AnalyticsEvents.SimpleBuy.sbPostKycNotEligible
        }
    }
}
