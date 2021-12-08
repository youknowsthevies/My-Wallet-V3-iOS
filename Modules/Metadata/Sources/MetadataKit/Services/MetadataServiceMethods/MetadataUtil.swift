// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct MetadataUtil {

    static func deriveHardened(
        node: PrivateKey,
        type: UInt32
    ) -> PrivateKey {
        node.derive(at: .hardened(type))
    }
}
