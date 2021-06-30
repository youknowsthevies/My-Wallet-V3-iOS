// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        viewStore.send(.appDelegate(.open(url)))
        return viewStore.appSettings.urlHandled
    }
}
