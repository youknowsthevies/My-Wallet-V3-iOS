// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation
import PlatformKit
import TransactionKit

extension AnalyticsEvents.New {
    public enum Send: AnalyticsEvent {
        public var type: AnalyticsEventType { .new }

        case sendReceiveClicked(origin: Origin = .navigation,
                                type: Type)
        case sendReceiveViewed(type: Type)
        case sendAmountMaxClicked(currency: String,
                                  fromAccountType: FromAccountType,
                                  toAccountType: ToAccountType)
        case sendFeeRateSelected(currency: String,
                                 feeRate: FeeRate,
                                 fromAccountType: FromAccountType,
                                 toAccountType: ToAccountType)
        case sendFromSelected(currency: String,
                              fromAccountType: FromAccountType)
        case sendSubmitted(currency: String,
                           feeRate: FeeRate,
                           fromAccountType: FromAccountType,
                           toAccountType: ToAccountType)

        public enum Origin: String, StringRawRepresentable {
            case navigation = "NAVIGATION"
        }

        public enum `Type`: String, StringRawRepresentable {
            case receive = "RECEIVE"
            case send = "SEND"
        }

        public enum FromAccountType: String, StringRawRepresentable {
            case savings = "SAVINGS"
            case trading = "TRADING"
            case userKey = "USERKEY"
            case unknown = "UNKNOWN"

            public init(_ account: BlockchainAccount) {
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

        public enum ToAccountType: String, StringRawRepresentable {
            case external = "EXTERNAL"
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
                case nil:
                    self = .external
                default:
                    self = .unknown
                }
            }
        }

        public enum FeeRate: String, StringRawRepresentable {
            case custom = "CUSTOM"
            case normal = "NORMAL"
            case priority = "PRIORITY"

            init(_ feeLevel: FeeLevel) {
                switch feeLevel {
                case .priority:
                    self = .priority
                case .custom:
                    self = .custom
                default:
                    self = .normal
                }
            }
        }
    }
}
