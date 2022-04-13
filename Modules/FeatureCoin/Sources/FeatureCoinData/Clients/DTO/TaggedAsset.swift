// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct TaggedAsset: Decodable {
    public struct Tag: Decodable {
        public let tag: String
        public let insertedAt: String
    }

    public let asset: String
    public let insertedAt: String
    public let updatedAt: String
    public let tags: [Tag]
}
