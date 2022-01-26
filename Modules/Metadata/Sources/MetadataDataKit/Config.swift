// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

enum Metadata {

    struct Config {

        let host: String
        let code: String

        init(host: String, code: String) {
            self.host = host
            self.code = code
        }
    }
}
