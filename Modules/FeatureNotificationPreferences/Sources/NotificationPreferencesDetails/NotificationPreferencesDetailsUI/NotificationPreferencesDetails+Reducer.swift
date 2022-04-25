// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Foundation
import FeatureNotificationPreferencesDomain

public let notificationPreferencesDetailsReducer = Reducer<
    NotificationPreferencesDetailsState,
    NotificationPreferencesDetailsAction,
    NotificationPreferencesDetailsEnvironment
> { state, action, environment in
    switch action {
    case .save:
        return .none
    case .binding:
        return .none
    }
}
.binding()
