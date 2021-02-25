//
//  MockDeepLinkRouter.swift
//  TestKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

final class MockDeepLinkRouter: DeepLinkRouting {
    var underlyingRouteIfNeeded: Bool = false
    func routeIfNeeded() -> Bool {
        underlyingRouteIfNeeded
    }
}
