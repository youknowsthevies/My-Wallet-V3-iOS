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
        let feature = AppFeature.polygonSupport.remoteEnabledKey
        guard let value = try? app.remoteConfiguration.get(feature) else {
            return false
        }
        let isEnabled = value as? Bool ?? false
        return isEnabled
    }()

    private let lock = NSLock()
    private let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }
}
