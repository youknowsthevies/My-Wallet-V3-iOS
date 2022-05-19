// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import MoneyKit
import ToolKit

final class PolygonSupport: MoneyKit.PolygonSupport {

    var isEnabled: Bool {
        defer { lock.unlock() }
        lock.lock()
        return isEnabledLazy
    }

    private lazy var isEnabledLazy: Bool = {
        let ref = BlockchainNamespace.blockchain.app.configuration.polygon.is.enabled[].reference
        guard let value = try? app.remoteConfiguration.get(ref) else {
            return false
        }
        guard let isEnabled = value as? Bool else {
            return false
        }
        return isEnabled
    }()

    private let lock = NSLock()
    private let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }
}
