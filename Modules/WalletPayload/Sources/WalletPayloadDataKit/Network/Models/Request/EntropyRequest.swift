// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct EntropyRequest {
    let bytes: Int
    let format: EntropyFormat
}

extension EntropyRequest {
    var parameters: [URLQueryItem] {
        [
            URLQueryItem(
                name: "bytes",
                value: String(bytes)
            ),
            URLQueryItem(
                name: "format",
                value: format.rawValue
            )
        ]
    }
}
