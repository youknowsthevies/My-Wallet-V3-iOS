// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit

extension AnalyticsEvents.New {
    enum Interest: AnalyticsEvent {

        var type: AnalyticsEventType { .nabu }

        case interestDepositViewed(currency: String)
        case interestWithdrawalViewed(currency: String)

        case interestDepositAmountEntered(currency: String)

        case interestDepositMaxAmountClicked(
            currency: String,
            fromAccountType: FromAccountType
        )
        case walletRewardsWithdrawMaxAmountClicked(currency: String)

        case walletRewardsDepositTransferClicked(
            amount: Double,
            amountUsd: Double,
            currency: String,
            type: FromAccountType
        )
        case walletRewardsWithdrawTransferClicked(
            amount: Double,
            amountUsd: Double,
            currency: String,
            type: FromAccountType
        )

        enum FromAccountType: String, StringRawRepresentable {
            case trading = "TRADING"
            case userkey = "USERKEY"

            init(_ account: BlockchainAccount?) {
                switch account?.accountType {
                case .nonCustodial:
                    self = .userkey
                default:
                    self = .trading
                }
            }
        }
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.Interest) {
        record(event: event)
    }
}
