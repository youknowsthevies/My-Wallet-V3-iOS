// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Embeds any nesting types: e.g topics and types of notifications
public enum RemoteNotification {
    /// A data bag for push notification format
    public enum NotificationType {

        case general
    }

    public enum Topic: String {
        case remoteConfig = "PUSH_RC"
    }

    /// Remote notification token representation
    public typealias Token = String

    /// Potential errors during token fetching
    public enum TokenFetchError: Error {

        /// Embeds any firebase error
        case external(Error)

        /// Token is empty
        case tokenIsEmpty

        /// Result is nullified
        case resultIsNil
    }
}
