import AnalyticsKit
import PlatformKit

extension AnalyticsEvents.New {

    public enum KYC: AnalyticsEvent {

        public var type: AnalyticsEventType {
            .nabu
        }

        // Trading Limits and Upgrade Prompt
        case tradingLimitsViewed(tier: Int)
        case tradingLimitsDismissed(tier: Int)
        case tradingLimitsGetBasicCTAClicked(tier: Int)
        case tradingLimitsGetVerifiedCTAClicked(tier: Int)

        // Verify Now Alert
        case verifyNowPopUpViewed
        case verifyNowPopUpDismissed
        case verifyNowPopUpCTAClicked

        // Verification Screen (prompt to upload an ID during the KYC flow)
        case preVerificationViewed
        case preVerificationDismissed
        case preVerificationCTAClicked

        // Account Usage Questions
        case accountInfoSubmitted
        case accountInfoScreenViewed
    }
}
