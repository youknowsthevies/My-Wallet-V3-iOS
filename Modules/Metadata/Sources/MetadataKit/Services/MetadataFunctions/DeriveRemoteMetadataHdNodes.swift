// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

func deriveRemoteMetadataHdNodes(
    from masterKey: MasterKey
) -> Result<RemoteMetadataNodes, MetadataDerivationError> {
    MetadataDerivation().deriveMetadataNode(node: masterKey)
        .flatMap { metadataNode -> Result<RemoteMetadataNodes, MetadataDerivationError> in
            MetadataDerivation().deriveSharedMetadataNode(node: masterKey)
                .map { sharedMetadataNode -> RemoteMetadataNodes in
                    RemoteMetadataNodes(
                        sharedMetadataNode: sharedMetadataNode,
                        metadataNode: metadataNode
                    )
                }
        }
}
