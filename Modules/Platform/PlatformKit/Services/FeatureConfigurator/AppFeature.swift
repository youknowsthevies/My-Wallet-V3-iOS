// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
@objc
public enum AppFeature: Int, CaseIterable {

    // MARK: - Local features

    case biometry
    case swipeToReceive

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
            // TODO: (paulo) Modern Wallet P3 - Use "secure_channel_ios".
            return "secure_channel_ios_dev"
        case .tradingAccountReceive:
            return "trading_account_receive_ios"
        case .tradingAccountExternalSend:
            return "trading_account_external_send_ios"
        case .sendToDomainName:
            return "send_to_domain_name_ios"
        case .biometry,
             .swipeToReceive:
            return nil
        }
    }
}
