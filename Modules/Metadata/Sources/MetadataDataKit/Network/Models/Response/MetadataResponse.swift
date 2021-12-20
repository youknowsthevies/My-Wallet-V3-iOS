// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

struct MetadataResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case version
        case payload
        case signature
        case prevMagicHash = "prev_magic_hash"
        case typeId = "type_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case address
    }

    var version: Int = 0
    var payload: String = ""
    var signature: String = ""
    var prevMagicHash: String?
    var typeId: Int = 0
    var createdAt: Int = 0
    var updatedAt: Int = 0
    var address: String = ""

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        payload = try values.decode(String.self, forKey: .payload)
        version = try values.decode(Int.self, forKey: .version)
        typeId = try values.decode(Int.self, forKey: .typeId)
        signature = try values.decode(String.self, forKey: .signature)
        prevMagicHash = try values.decodeIfPresent(String.self, forKey: .prevMagicHash)
        createdAt = try values.decode(Int.self, forKey: .createdAt)
        updatedAt = try values.decode(Int.self, forKey: .updatedAt)
        address = try values.decode(String.self, forKey: .address)
    }
}

extension MetadataPayload {

    init(from response: MetadataResponse) {
        self.init(
            version: response.version,
            payload: response.payload,
            signature: response.signature,
            prevMagicHash: response.prevMagicHash,
            typeId: response.typeId,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
            address: response.address
        )
    }
}
