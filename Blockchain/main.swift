// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// temporary top-level decision based on environment variable `bootstrap_work`
/// to either use the new `AppDelegate` which uses `ComposableArchitecture` or the older `BlockchainAppDelegate`
var appDelegateClass: String {
    NSStringFromClass(AppDelegate.self)
}

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    appDelegateClass
)
