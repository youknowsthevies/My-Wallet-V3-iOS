// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureNotificationPreferencesDomain
import Foundation

public let notificationPreferencesDetailsReducer = Reducer<
    NotificationPreferencesDetailsState,
    NotificationPreferencesDetailsAction,
    NotificationPreferencesDetailsEnvironment
> { _, action, _ in
    switch action {
    case .onAppear:
        return .none
    case .save:
        return .none
    case .binding:
        return .none
    }
}
.binding()
