// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

func deriveRemoteMetadataHdNodes(
    from masterKey: MasterKey
) -> Result<RemoteMetadataNodes, MetadataDerivationError> {
    MetadataDerivation().deriveMetadataNode(node: masterKey)
        .map { metadataNode -> RemoteMetadataNodes in
            RemoteMetadataNodes(
                metadataNode: metadataNode
            )
        }
}
