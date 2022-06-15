// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataInitError: Error {
    case invalidPayload(RemoteMetadataNodesDecodingError)
    case failedToInitNodes
}

func initNodes(
    remoteMetadataNodesResponse: RemoteMetadataNodesResponse
) -> Result<RemoteMetadataNodes, MetadataInitError> {
    RemoteMetadataNodesPayload.from(response: remoteMetadataNodesResponse)
        .mapError(MetadataInitError.invalidPayload)
        .flatMap { remoteMetadataNodes -> Result<RemoteMetadataNodes, MetadataInitError> in
            let metadataNodeResult = deserializeMetadataNode(
                node: remoteMetadataNodes.metadata
            )
            guard case .success(let metadataNode) = metadataNodeResult else {
                return .failure(.failedToInitNodes)
            }
            return .success(
                RemoteMetadataNodes(
                    metadataNode: metadataNode
                )
            )
        }
}
