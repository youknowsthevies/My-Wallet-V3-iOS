// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Legacy for old QR - should NOT be used in new components!
@objc class BridgeDeepLinkQRCodeRouter: NSObject {
    let router = DeepLinkQRCodeRouter(supportedRoutes: [.exchangeLinking])

    @objc func handle(deepLink: String) -> Bool {
        router.routeIfNeeded(using: deepLink)
    }
}
