// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AppStoreApplicationInfo: Equatable {
    public let version: String
    public let isApplicationUpToDate: Bool

    public init(
        version: String,
        isApplicationUpToDate: Bool
    ) {
        self.version = version
        self.isApplicationUpToDate = isApplicationUpToDate
    }
}
