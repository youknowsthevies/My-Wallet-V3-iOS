// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension AppDelegate {
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        viewStore.send(.appDelegate(.userActivity(userActivity)))
        return viewStore.state.userActivityHandled
    }
}
