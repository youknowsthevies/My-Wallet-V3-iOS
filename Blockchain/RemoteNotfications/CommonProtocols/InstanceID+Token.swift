// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Firebase
import FirebaseInstanceID
import RemoteNotificationsKit

extension InstanceID: RemoteNotificationTokenFetching {
    public func instanceID(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void) {
        instanceID { (result, error) in
            if let error = error {
                handler(.failure(.external(error)))
            } else if let result = result {
                if result.token.isEmpty {
                    handler(.failure(.tokenIsEmpty))
                } else {
                    handler(.success(result.token))
                }
            } else {
                handler(.failure(.resultIsNil))
            }
        }
    }
}
