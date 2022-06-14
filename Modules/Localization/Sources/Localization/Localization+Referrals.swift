// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum Referrals {
        public enum SettingsScreen {}
        public enum ReferralScreen {}
    }
}

extension LocalizationConstants.Referrals.SettingsScreen {
    public static let buttonTitle = NSLocalizedString(
        "Referral program",
        comment: "Referral program"
    )
}

extension LocalizationConstants.Referrals.ReferralScreen {
    public static let shareButton = NSLocalizedString(
        "Share",
        comment: "Share"
    )

    public static let stepsTitleLabel = NSLocalizedString(
        "What my invited friends need to do?",
        comment: "What my invited friends need to do?"
    )

    public static let referalCodeLabel = NSLocalizedString(
        "Your referral code",
        comment: "Your referral code"
    )

    public static let copyLabel = NSLocalizedString(
        "Copy",
        comment: "Copy"
    )

    public static let copiedLabel = NSLocalizedString(
        "Copied",
        comment: "Copied"
    )
}
