//
//  AnalyticsEvents+Blockchain.swift
//  KYCUIKit
//
//  Created by Daniel Huri on 03/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import ToolKit

extension AnalyticsEvents {

    enum KYC: AnalyticsEvent {
        case kycVerifyEmailButtonClick
        case kycCountrySelected
        case kycPersonalDetailSet(fieldName: String)
        case kycAddressDetailSet
        case kycVerifyIdStartButtonClick
        case kycVeriffInfoSubmitted
        case kycUnlockSilverClick
        case kycUnlockGoldClick
        case kycPhoneUpdateButtonClick
        case kycEmailUpdateButtonClick

        var name: String {
            switch self {
            // KYC - send verification email button click
            case .kycVerifyEmailButtonClick:
                return "kyc_verify_email_button_click"
            // KYC - country selected
            case .kycCountrySelected:
                return "kyc_country_selected"
            // KYC - personal detail changed
            case .kycPersonalDetailSet:
                return "kyc_personal_detail_set"
            // KYC - address changed
            case .kycAddressDetailSet:
                return "kyc_address_detail_set"
            // KYC - verify identity start button click
            case .kycVerifyIdStartButtonClick:
                return "kyc_verify_id_start_button_click"
            // KYC - info veriff info submitted
            case .kycVeriffInfoSubmitted:
                return "kyc_veriff_info_submitted"
            // KYC - unlock tier 1 (silver) clicked
            case .kycUnlockSilverClick:
                return "kyc_unlock_silver_click"
            // KYC - unlock tier 1 (silver) clicked
            case .kycUnlockGoldClick:
                return "kyc_unlock_gold_click"
            // KYC - phone number update button click
            case .kycPhoneUpdateButtonClick:
                return "kyc_phone_update_button_click"
            // KYC - email update button click
            case .kycEmailUpdateButtonClick:
                return "kyc_email_update_button_click"
            }
        }

        var params: [String: String]? {
            nil
        }
    }
}
