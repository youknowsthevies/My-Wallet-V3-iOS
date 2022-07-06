//
//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.
//

import CryptoKit
import Foundation

extension String {

    func sha256() -> String {
        let hash = CryptoKit.SHA256.hash(data: Data(utf8))
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
