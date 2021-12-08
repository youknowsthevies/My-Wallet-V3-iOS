// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum RemoteMetadataNodesDecodingError: Error {
    case invalidPayload
}

struct RemoteMetadataNodesPayload {
    var metadata: String
    var mdid: String
}

extension RemoteMetadataNodesPayload {

    var response: RemoteMetadataNodesResponse {
        RemoteMetadataNodesResponse(
            metadata: metadata,
            mdid: mdid
        )
    }

    static func from(
        response: RemoteMetadataNodesResponse
    ) -> Result<Self, RemoteMetadataNodesDecodingError> {
        guard
            let metadata = response.metadata,
            let mdid = response.mdid
        else {
            return .failure(.invalidPayload)
        }
        return .success(
            RemoteMetadataNodesPayload(metadata: metadata, mdid: mdid)
        )
    }
}
