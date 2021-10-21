// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import RxRelay
import RxSwift

final class CashIdentityVerificationRouter {

    private weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    private let kycRouter: KYCRouterAPI

    init(
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        kycRouter: KYCRouterAPI = resolve()
    ) {
        self.kycRouter = kycRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }

    func dismiss(startKYC: Bool = false) {
        let kycRouter = kycRouter
        topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: {
            guard startKYC else { return }
            kycRouter.start(parentFlow: .cash)
        })
    }
}
