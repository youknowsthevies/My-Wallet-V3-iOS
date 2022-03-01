// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension AppDelegate {
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if let url = userActivity.webpageURL {
            app.post(
                event: blockchain.app.process.deep_link,
                context: [blockchain.app.process.deep_link.url[]: url]
            )
        }
        viewStore.send(.appDelegate(.userActivity(userActivity)))
        return viewStore.appSettings.userActivityHandled
    }
}
