// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol KeychainQueryProvider {
    func query() -> [String: Any]
}
