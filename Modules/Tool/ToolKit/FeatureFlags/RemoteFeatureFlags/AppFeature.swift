// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
@objc
public enum AppFeature: Int, CaseIterable {

    // MARK: - Local features

    case biometry

    // MARK: - Firebase features

    /// The announcements
    case announcements

    /// Sift Science SDK is enabled
    case siftScienceEnabled

    /// Enable Secure Channel
    case secureChannel

    /// Enable receiving to trading account
    case tradingAccountReceive

    /// Enable sending from a trading account to any crypto address.
    case tradingAccountExternalSend

    /// Enable resolving a domain name when sending crypto.
    case sendToDomainName

    // MARK: Onboarding (After Login)

    /// Shows Email Verification insted of Simple Buy at Login
    case showOnboardingAfterSignUp

    /// Shows Email Verification in Onboarding, otherwise just show the buy flow
    case showEmailVerificationInOnboarding

    /// Shows Email Verification, if needed, when a user tries to make a purchase
    case showEmailVerificationInBuyFlow

    // MARK: SDD

    /// Enables SDD checks. If `false`, all checks immediately fail
    case sddEnabled
}

extension AppFeature {
    /// The remote key which determines if this feature is enabled or not
    public var remoteEnabledKey: String? {
        switch self {
        case .announcements:
            return "announcements"
        case .siftScienceEnabled:
            return "sift_science_enabled"
        case .secureChannel:
            return "secure_channel_ios"
        case .tradingAccountReceive:
            return "trading_account_receive_ios"
        case .tradingAccountExternalSend:
            return "trading_account_external_send_ios"
        case .sendToDomainName:
            return "send_to_domain_name_ios"
        case .biometry:
            return nil
        case .showOnboardingAfterSignUp:
            return "show_onboarding_after_sign_up_ios"
        case .showEmailVerificationInOnboarding:
            return "show_email_verification_in_onboarding_ios"
        case .showEmailVerificationInBuyFlow:
            return "show_email_verification_in_buy_flow_ios"
        case .sddEnabled:
            return "sdd_enabled_ios"
        }
    }
}
