//
//  MockDeepLinkHandler.swift
//  TestKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

final class MockDeepLinkHandler: DeepLinkHandling {
    var handleValue: (String, [DeepLinkRoute])!
    func handle(deepLink: String, supportedRoutes: [DeepLinkRoute]) {
        handleValue = (deepLink, supportedRoutes)
    }
}
