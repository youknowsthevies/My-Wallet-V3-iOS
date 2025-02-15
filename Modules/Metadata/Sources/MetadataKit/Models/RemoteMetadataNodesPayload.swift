// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum RemoteMetadataNodesDecodingError: Error {
    case invalidPayload
}

struct RemoteMetadataNodesPayload {
    var metadata: String
}

extension RemoteMetadataNodesPayload {

    var response: RemoteMetadataNodesResponse {
        RemoteMetadataNodesResponse(
            metadata: metadata
        )
    }

    static func from(
        response: RemoteMetadataNodesResponse
    ) -> Result<Self, RemoteMetadataNodesDecodingError> {
        guard let metadata = response.metadata else {
            return .failure(.invalidPayload)
        }
        return .success(
            RemoteMetadataNodesPayload(
                metadata: metadata
            )
        )
    }
}
