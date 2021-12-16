// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

struct MetadataBodyRequest: Encodable {

    enum CodingKeys: String, CodingKey {
        case version
        case payload
        case signature
        case prevMagicHash = "prev_magic_hash"
        case typeId = "type_id"
    }

    var version: Int
    var payload: String
    var signature: String
    var prevMagicHash: String?
    var typeId: Int
}

extension MetadataBody {

    var request: MetadataBodyRequest {
        MetadataBodyRequest(
            version: version,
            payload: payload,
            signature: signature,
            prevMagicHash: prevMagicHash,
            typeId: typeId
        )
    }
}
