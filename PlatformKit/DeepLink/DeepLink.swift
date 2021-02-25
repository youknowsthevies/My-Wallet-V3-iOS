//
//  DeepLink.swift
//  PlatformKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

public enum DeepLinkRoute: CaseIterable {
    case xlmAirdop
    case kyc
    case kycVerifyEmail
    case kycDocumentResubmission
    case exchangeVerifyEmail
    case exchangeLinking
}

public protocol DeepLinkHandling {
    func handle(deepLink: String)
    func handle(deepLink: String, supportedRoutes: [DeepLinkRoute])
}

extension DeepLinkHandling {
    public func handle(deepLink: String) {
        handle(deepLink: deepLink, supportedRoutes: DeepLinkRoute.allCases)
    }
}
