// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WatchlistResponse: Decodable {
    public let assets: [TaggedAsset]
}
