// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct RemoteMetadataNodesResponse: Codable {

    var areAllMetadataNodesAvailable: Bool {
        metadata != nil
    }

    var metadata: String?
}
