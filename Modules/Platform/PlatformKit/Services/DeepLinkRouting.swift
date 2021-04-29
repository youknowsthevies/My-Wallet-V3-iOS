// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol DeepLinkRouting {
    /// Returns true if routing was performed
    func routeIfNeeded() -> Bool
}
