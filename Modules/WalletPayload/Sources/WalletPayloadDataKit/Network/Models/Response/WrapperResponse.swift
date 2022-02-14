// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct WrapperResponse: Equatable, Codable {
    let guid: String
    let sharedKey: String
    let oldChecksum: String
    let language: String
    let checksum: String
    let length: Int
    let payload: InnerWrapper

    enum CodingKeys: String, CodingKey {
        case guid
        case sharedKey
        case oldChecksum = "old_checksum"
        case language
        case checksum
        case length
        case payload
    }
}

struct InnerWrapper: Equatable, Codable {
    let pbkdf2IterationCount: UInt32
    let version: Int
    let payload: String

    enum CodingKeys: String, CodingKey {
        case pbkdf2IterationCount = "pbkdf2_iterations"
        case version
        case payload
    }
}
