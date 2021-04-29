//
//  KYC.Tier.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

extension KYC.Tier {

    public var headline: String? {
        switch self {
        case .tier0:
            return nil
        case .tier1:
            return nil
        case .tier2:
            return LocalizationConstants.KYC.freeCrypto
        }
    }
    
    public var tierDescription: String {
        switch self {
        case .tier0:
            return "Tier Zero Verification"
        case .tier1:
            return LocalizationConstants.KYC.tierOneVerification
        case .tier2:
            return LocalizationConstants.KYC.tierTwoVerification
        }
    }
    
    public var requirementsDescription: String {
        switch self {
        case .tier0:
            return ""
        case .tier1:
            return LocalizationConstants.KYC.tierOneRequirements
        case .tier2:
            return LocalizationConstants.KYC.tierTwoRequirements
        }
    }
    
    public var limitTimeframe: String {
        switch self {
        case .tier0:
            return "locked"
        case .tier1:
            return LocalizationConstants.KYC.annualSwapLimit
        case .tier2:
            return LocalizationConstants.KYC.dailySwapLimit
        }
    }
    
    public var duration: String {
        switch self {
        case .tier0:
            return "0 minutes"
        case .tier1:
            return LocalizationConstants.KYC.takesThreeMinutes
        case .tier2:
            return LocalizationConstants.KYC.takesTenMinutes
        }
    }
}
