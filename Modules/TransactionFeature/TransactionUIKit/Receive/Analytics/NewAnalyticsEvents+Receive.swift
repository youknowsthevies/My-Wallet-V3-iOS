// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation
import PlatformKit

extension AnalyticsEvents.New {
    public enum Receive: AnalyticsEvent {
        public var type: AnalyticsEventType { .new }

        case receiveCurrencySelected(accountType: AccountType, currency: String)
        case receiveDetailsCopied(accountType: AccountType, currency: String)

        public enum AccountType: String, StringRawRepresentable {
            case savings = "SAVINGS"
            case trading = "TRADING"
            case userKey = "USERKEY"
            case unknown = "UNKNOWN"

            public init(_ account: BlockchainAccount?) {
                switch account {
                case is CryptoNonCustodialAccount:
                    self = .userKey
                case is CryptoInterestAccount:
                    self = .savings
                case is CryptoTradingAccount:
                    self = .trading
                default:
                    self = .unknown
                }
            }
        }
    }
}
