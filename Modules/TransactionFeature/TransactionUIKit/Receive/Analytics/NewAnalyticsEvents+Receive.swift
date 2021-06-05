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

            public init(_ cryptoAccount: CryptoAccount?) {
                switch cryptoAccount?.accountType {
                case .nonCustodial:
                    self = .userKey
                case .custodial(.savings):
                    self = .savings
                case .custodial(.trading):
                    self = .trading
                default:
                    self = .unknown
                }
            }
        }
    }
}
