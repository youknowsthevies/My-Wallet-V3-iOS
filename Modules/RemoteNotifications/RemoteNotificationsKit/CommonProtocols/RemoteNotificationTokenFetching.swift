// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public typealias RemoteNotificationTokenFetchResult = Result<RemoteNotification.Token, RemoteNotification.TokenFetchError>

/// This is used to separate firebase from the rest of the remote notification logic
public protocol RemoteNotificationTokenFetching: class {
    func instanceID(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void)
}
