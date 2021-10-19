// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import ToolKit

extension Reachability {

    /// Checks if the device has internet connectivity
    @objc static func hasInternetConnection() -> Bool {
        let reachability = Reachability.forInternetConnection()
        guard reachability?.currentReachabilityStatus() != NetworkStatus.NotReachable else {
            Logger.shared.info("No internet connection.")
            return false
        }
        return true
    }
}

public final class InternetReachability: InternetReachabilityAPI {

    public var canConnect: Bool {
        Reachability.hasInternetConnection()
    }

    public init() {}
}
