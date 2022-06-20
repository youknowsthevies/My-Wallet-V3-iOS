// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Foundation

public struct ExplainerService {

    public let app: AppProtocol
    public let defaults: UserDefaults

    public init(app: AppProtocol, defaults: UserDefaults = .standard) {
        self.app = app
        self.defaults = defaults
    }

    private let key = blockchain.ux.asset.account.explainer(\.id)

    public func resetAll() {
        defaults.removeObject(forKey: key)
    }

    public func reset(_ account: Account.Snapshot) {
        set(account, to: false)
    }

    public func accept(_ account: Account.Snapshot) {
        set(account, to: true)
    }

    private func set(_ account: Account.Snapshot, to seen: Bool) {
        var explainer = defaults.object(forKey: key)
        explainer[dotPath: account.accountType.rawValue] = seen
        defaults.set(explainer, forKey: key)
    }

    public func isAccepted(_ account: Account.Snapshot) -> Bool {
        (defaults.object(forKey: key)[dotPath: account.accountType.rawValue] as? Bool) ?? false
    }
}

extension ExplainerService {
    public static var preview: ExplainerService {
        .init(app: App.preview)
    }
}
