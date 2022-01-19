// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct RecoveryContext: Equatable {

    public var guid: String {
        credentials.guid
    }

    public var sharedKey: String {
        credentials.sharedKey
    }

    public var password: String {
        credentials.password
    }

    public let metadataState: MetadataState

    public let credentials: Credentials
}
