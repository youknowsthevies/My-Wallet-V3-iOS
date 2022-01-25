// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {

    enum OnboardingChecklist: AnalyticsEvent {

        public var type: AnalyticsEventType {
            .nabu
        }

        case peeksheetViewed(currentStepCompleted: Int)
        case peeksheetDismissed(currentStepCompleted: Int)
        case peeksheetProcessClicked(currentStepCompleted: Int)
        case peeksheetSelectionClicked(
            buttonClicked: Bool,
            currentStepCompleted: Int,
            item: PeeksheetItem
        )

        enum PeeksheetItem: String, StringRawRepresentable {

            case buyCrypto = "BUY_CRYPTO"
            case linkPayment = "LINK_PAYMENT"
            case verifyIdentity = "VERIFY"

            init?(item: FeatureOnboardingUI.OnboardingChecklist.Item.Identifier) {
                switch item {
                case .buyCrypto:
                    self = .buyCrypto
                case .linkPaymentMethods:
                    self = .linkPayment
                case .verifyIdentity:
                    self = .verifyIdentity
                default:
                    return nil
                }
            }
        }
    }
}
