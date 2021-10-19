// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import FeatureAuthenticationDomain

extension AnalyticsEvents.New {
    enum AccountRecoveryFlow: AnalyticsEvent, Equatable {
        case importWalletCancelled
        case importWalletClicked
        case importWalletConfirmed
        case recoveryOptionSelected
        case recoveryPhraseEntered
        case resetAccountCancelled
        case resetAccountClicked

        var type: AnalyticsEventType { .nabu }
    }
}

extension AnalyticsEventRecorderAPI {
    /// Helper method to record `AccountRecoveryFlow` events
    /// - Parameter event: A `AccountRecoveryFlow` event to be tracked
    func record(event: AnalyticsEvents.New.AccountRecoveryFlow) {
        record(event: event)
    }
}
