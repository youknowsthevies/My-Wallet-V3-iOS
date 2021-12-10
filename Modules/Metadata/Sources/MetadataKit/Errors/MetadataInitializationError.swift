// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataInitialisationError: Error {
    case failedToDeriveSecondPasswordNode(DeriveSecondPasswordNodeError)
    case failedToLoadRemoteMetadataNode(LoadRemoteMetadataError)
    case failedToDecodeRemoteMetadataNode(DecodingError)
    case failedToDeriveRemoteMetadataNode(MetadataInitError)
    case failedToGenerateNodes(Error)
}
