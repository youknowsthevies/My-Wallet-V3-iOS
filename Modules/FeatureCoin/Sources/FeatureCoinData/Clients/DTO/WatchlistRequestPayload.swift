// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WatchlistRequestPayload: Encodable {
    public let asset: String
    public let tags: [String]

    public init(asset: String, tags: [String]) {
        self.asset = asset
        self.tags = tags
    }
}
