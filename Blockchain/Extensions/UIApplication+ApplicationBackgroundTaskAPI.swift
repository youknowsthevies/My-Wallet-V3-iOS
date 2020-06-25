//
//  UIApplication+ApplicationBackgroundTaskAPI.swift
//  Blockchain
//
//  Created by Paulo on 19/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

extension UIApplication: ApplicationBackgroundTaskAPI {
    public func beginToolKitBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Void)?) -> BackgroundTaskIdentifier {
        BackgroundTaskIdentifier(identifier: beginBackgroundTask(withName: taskName, expirationHandler: handler))
    }

    public func endToolKitBackgroundTask(_ identifier: BackgroundTaskIdentifier) {
        endBackgroundTask(identifier.identifier as! UIBackgroundTaskIdentifier)
    }
}
