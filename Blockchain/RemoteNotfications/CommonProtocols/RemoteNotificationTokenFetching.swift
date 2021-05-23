// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RemoteNotificationsKit

typealias RemoteNotificationTokenFetchResult = Result<RemoteNotification.Token, RemoteNotification.TokenFetchError>

/// This is used to separate firebase from the rest of the remote notification logic
protocol RemoteNotificationTokenFetching: class {
    func instanceID(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void)
}
