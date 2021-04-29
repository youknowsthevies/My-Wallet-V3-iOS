// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

final class MockDeepLinkRouter: DeepLinkRouting {
    var underlyingRouteIfNeeded: Bool = false
    func routeIfNeeded() -> Bool {
        underlyingRouteIfNeeded
    }
}
