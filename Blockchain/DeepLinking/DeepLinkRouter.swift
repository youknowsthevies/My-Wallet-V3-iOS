//
//  DeepLinkRouter.swift
//  Blockchain
//
//  Created by kevinwu on 1/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import KYCUIKit

class DeepLinkRouter {

    private let routers: [DeepLinkRouting]

    init(routers: [DeepLinkRouting] = [
        KYCDeepLinkRouter(),
        KYCResubmitIdentityRouter(),
        ExchangeDeepLinkRouter(),
        BitPayLinkRouter()
    ]) {
        self.routers = routers
    }

    @discardableResult
    func routeIfNeeded() -> Bool {
        routers.map { $0.routeIfNeeded() }.first { $0 } ?? false
    }
}
