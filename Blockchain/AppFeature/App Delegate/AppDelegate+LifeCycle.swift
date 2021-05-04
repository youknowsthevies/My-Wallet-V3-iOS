// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension AppDelegate {
    func applicationWillResignActive(_ application: UIApplication) {
        viewStore.send(.appDelegate(.willResignActive))
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        viewStore.send(.appDelegate(.didEnterBackground(application)))
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        viewStore.send(.appDelegate(.willEnterForeground(application)))
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        viewStore.send(.appDelegate(.didBecomeActive))
    }
}
