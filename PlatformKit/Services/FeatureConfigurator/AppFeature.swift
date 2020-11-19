//
//  AppFeature.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
@objc
public enum AppFeature: Int, CaseIterable {
    case biometry
    case swipeToReceive
    case transferFundsFromImportedAddress

    /// Exchange linking enabled
    case exchangeLinking

    /// Exchange announcement visibility
    case exchangeAnnouncement

    /// The announcements
    case announcements

    /// Is simple buy enabled
    case simpleBuyEnabled

    /// Is simple buy card payment method enabled
    case simpleBuyCardsEnabled

    /// Is simple buy funds payment method enabled
    case simpleBuyFundsEnabled
    
    /// Is interest account enabled
    case interestAccountEnabled

    /// Is Swap 2.0 enabled
    case newSwapEnabled

    case wDGLDenabled
}

extension AppFeature {
    /// The remote key which determines if this feature is enabled or not
    public var remoteEnabledKey: String? {
        switch self {
        case .exchangeLinking:
            return "pit_linking_enabled"
        case .exchangeAnnouncement:
            return "pit_show_announcement"
        case .announcements:
            return "announcements"
        case .simpleBuyEnabled:
            return "simple_buy_enabled"
        case .simpleBuyCardsEnabled:
            return "simple_buy_method_card_enabled"
        case .simpleBuyFundsEnabled:
            return "simple_buy_method_funds_enabled"
        case .interestAccountEnabled:
            return "interest_account_enabled"
        case .newSwapEnabled:
            return "new_swap_enabled"
        case .wDGLDenabled:
            return "wdgld_enabled"
        case .biometry,
             .swipeToReceive,
             .transferFundsFromImportedAddress:
            return nil
        }
    }
}
