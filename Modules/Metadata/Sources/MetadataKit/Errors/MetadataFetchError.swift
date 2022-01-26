// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataFetchError: FromDecodingError {
    case loadMetadataError(LoadRemoteMetadataError)
    case failedToDeriveMetadataNode(MetadataNodeError)
    case decodingError(DecodingError)

    public static func from(_ decodingError: DecodingError) -> Self {
        .decodingError(decodingError)
    }
}
