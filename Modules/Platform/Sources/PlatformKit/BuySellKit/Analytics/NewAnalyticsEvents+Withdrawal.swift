// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    public enum Withdrawal: AnalyticsEvent {

        public var type: AnalyticsEventType { .nabu }

        case linkBankClicked(origin: LinkBank.Origin)

        case withdrawalAmountEntered(
            currency: String,
            inputAmount: Double,
            outputAmount: Double,
            withdrawalMethod: Withdrawal.Method
        )
        case withdrawalAmountMaxClicked(
            amountCurrency: String?,
            currency: String,
            withdrawalMethod: Withdrawal.Method
        )
        case withdrawalAmountMinClicked(
            amountCurrency: String?,
            currency: String,
            withdrawalMethod: Withdrawal.Method
        )
        case withdrawalClicked(origin: Withdrawal.Origin)
        case withdrawalMethodSelected(
            currency: String,
            withdrawalMethod: Withdrawal.Method
        )
        case withdrawalViewed

        public enum LinkBank {
            public enum Origin: String, StringRawRepresentable {
                case buy = "BUY"
                case deposit = "DEPOSIT"
                case settings = "SETTINGS"
                case withdraw = "WITHDRAW"
            }
        }

        public enum Withdrawal {
            public enum Method: String, StringRawRepresentable {
                case bankAccount = "BANK_ACCOUNT"
                case bankTransfer = "BANK_TRANSFER"
            }

            public enum Origin: String, StringRawRepresentable {
                case currencyPage = "CURRENCY_PAGE"
                case portfolio = "PORTFOLIO"
            }
        }
    }
}
