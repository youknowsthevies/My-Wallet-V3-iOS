// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct RemoteMetadataNodesResponse: Codable {

    var areAllMetadataNodesAvailable: Bool {
        metadata != nil && mdid != nil
    }

    var metadata: String?
    var mdid: String?
}
