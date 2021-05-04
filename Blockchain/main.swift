// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// temporary top-level decision based on environment variable `bootstrap_work`
/// to either use the new `AppDelegate` which uses `ComposableArchitecture` or the older `BlockchainAppDelegate`
var appDelegateClass: String {
    guard let bootstrapWork = ProcessInfo.processInfo.environment["bootstrap_work"] else {
        return NSStringFromClass(BlockchainAppDelegate.self)
    }
    guard let shouldUseNewBootstrap = Bool(bootstrapWork.lowercased()) else {
        return NSStringFromClass(BlockchainAppDelegate.self)
    }
    return shouldUseNewBootstrap
        ? NSStringFromClass(AppDelegate.self)
        : NSStringFromClass(BlockchainAppDelegate.self)
}

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    appDelegateClass
)
