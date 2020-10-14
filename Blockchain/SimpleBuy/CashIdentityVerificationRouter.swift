//
//  CashIdentityVerificationRouter.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformUIKit
import RxRelay
import RxSwift

final class CashIdentityVerificationRouter {
    
    private weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    private let kycRouter: KYCRouterAPI

    init(topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
         kycRouter: KYCRouterAPI = resolve()) {
        self.kycRouter = kycRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }
    
    func dismiss(startKYC: Bool = false) {
        let kycRouter = self.kycRouter
        topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: {
            guard startKYC else { return }
            kycRouter.start()
        })
    }
}
