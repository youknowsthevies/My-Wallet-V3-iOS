// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct RemoteMetadataNodes: Equatable {
    let metadataNode: PrivateKey
}

extension RemoteMetadataNodes {

    var payload: RemoteMetadataNodesPayload {
        RemoteMetadataNodesPayload(
            metadata: metadataNode.xpriv
        )
    }
}
