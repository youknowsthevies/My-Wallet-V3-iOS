// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import UIKit

extension AppDelegate {
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        viewStore.send(.appDelegate(.open(url)))
        app.post(
            event: blockchain.app.process.deep_link,
            context: [blockchain.app.process.deep_link.url: url]
        )
        return viewStore.appSettings.urlHandled
    }
}
