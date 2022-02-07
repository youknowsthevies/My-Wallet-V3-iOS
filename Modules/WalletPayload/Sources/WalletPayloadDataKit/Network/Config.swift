// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum WalletPayloadData {
    struct Config {
        let host: String
        let code: String

        init(host: String, code: String) {
            self.host = host
            self.code = code
        }
    }
}
