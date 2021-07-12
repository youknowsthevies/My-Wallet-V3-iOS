// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    public enum Onboarding: AnalyticsEvent {

        public var type: AnalyticsEventType {
            .new
        }

        case emailVerificationRequested(origin: EmailVerificationOrigin)
        case upgradeVerificationClicked(origin: UpgradeVerificationOrigin)

        public enum EmailVerificationOrigin: String, StringRawRepresentable {
            case signUp = "SIGN_UP"
            case verification = "VERIFICATION"
        }

        public enum UpgradeVerificationOrigin: String, StringRawRepresentable {
            case airdrop = "AIRDROP"
            case dashboardPromo = "DASHBOARD_PROMO"
            case fiatFunds = "FIAT_FUNDS"
            case onboarding = "ONBOARDING"
            case resubmission = "RESUBMISSION"
            case savings = "SAVINGS"
            case settings = "SETTINGS"
            case simplebuy = "SIMPLEBUY"
            case simpletrade = "SIMPLETRADE"
            case swap = "SWAP"
            case unknown = "UNKNOWN"
        }
    }
}
