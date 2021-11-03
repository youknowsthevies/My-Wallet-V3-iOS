// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
public enum AppFeature: Int, CaseIterable {

    // MARK: - Local features

    case biometry

    // MARK: - Firebase features

    /// The announcements
    case announcements

    /// The ticker for the new asset announcement.
    case newAssetAnnouncement

    /// The ticker for the asset rename announcement.
    case assetRenameAnnouncement

    /// Sift Science SDK is enabled
    case siftScienceEnabled

    /// Enable Secure Channel
    case secureChannel

    // MARK: Onboarding (After Login)

    /// Shows Email Verification insted of Simple Buy at Login
    case showOnboardingAfterSignUp

    /// Shows Email Verification in Onboarding, otherwise just show the buy flow
    case showEmailVerificationInOnboarding

    /// Shows Email Verification, if needed, when a user tries to make a purchase
    case showEmailVerificationInBuyFlow

    // MARK: - SSO

    case unifiedSignIn

    // MARK: - SDD

    /// Enables SDD checks. If `false`, all checks immediately fail
    case sddEnabled

    /// Enable ACH withdraw and deposit
    case withdrawAndDepositACH

    /// Enable interest withdraw and deposit
    case interestWithdrawAndDeposit

    /// Enable Zen-Desk Messaging for Gold Verified Users
    case customerSupportChat

    /// Enable new Sell Transaction flow
    case sellUsingTransactionFlowEnabled

    /// Enable Dynamic Assets
    case dynamicAssetsEnabled
}

extension AppFeature {
    /// The remote key which determines if this feature is enabled or not
    public var remoteEnabledKey: String? {
        switch self {
        case .interestWithdrawAndDeposit:
            return "ios_interest_deposit_withdraw"
        case .announcements:
            return "announcements"
        case .newAssetAnnouncement:
            return "new_asset_announcement_ticker"
        case .assetRenameAnnouncement:
            return "rename_asset_announcement_ticker"
        case .siftScienceEnabled:
            return "sift_science_enabled"
        case .secureChannel:
            return "secure_channel_ios"
        case .withdrawAndDepositACH:
            return "ach_withdraw_deposit_enabled"
        case .biometry:
            return nil
        case .showOnboardingAfterSignUp:
            return "show_onboarding_after_sign_up_ios"
        case .showEmailVerificationInOnboarding:
            return "show_email_verification_in_onboarding_ios"
        case .showEmailVerificationInBuyFlow:
            return "show_email_verification_in_buy_flow_ios"
        case .unifiedSignIn:
            return "sso_unified_sign_in_enabled_ios"
        case .sddEnabled:
            return "sdd_enabled_ios"
        case .customerSupportChat:
            return "customer_support_chat_ios"
        case .sellUsingTransactionFlowEnabled:
            return "sell_using_transaction_flow_enabled_ios"
        case .dynamicAssetsEnabled:
            return "dynamic_assets_ios"
        }
    }

    /// Enables the feature for alpha release by overriding remote config settings.
    var isAlphaReady: Bool {
        switch self {
        case .newAssetAnnouncement:
            return false
        case .assetRenameAnnouncement:
            return false
        case .interestWithdrawAndDeposit:
            return false
        case .announcements:
            return false
        case .siftScienceEnabled:
            return false
        case .secureChannel:
            return false
        case .withdrawAndDepositACH:
            return false
        case .biometry:
            return false
        case .showOnboardingAfterSignUp:
            return false
        case .showEmailVerificationInOnboarding:
            return false
        case .showEmailVerificationInBuyFlow:
            return false
        case .unifiedSignIn:
            return false
        case .sddEnabled:
            return false
        case .customerSupportChat:
            return false
        case .sellUsingTransactionFlowEnabled,
             .dynamicAssetsEnabled:
            return true
        }
    }
}

public struct AssetRenameAnnouncementFeature: Decodable {
    public let networkTicker: String
    public let oldTicker: String
}
