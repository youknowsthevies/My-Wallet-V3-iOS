// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

public enum KYCParentFlow {
    case simpleBuy
    case none
}

public protocol KYCRouterAPI: class {
    var tier1Finished: Observable<Void> { get }
    var tier2Finished: Observable<Void> { get }
    var kycStopped: Observable<KYC.Tier> { get }
    func start()
    func start(tier: KYC.Tier)
    func start(from viewController: UIViewController, tier: KYC.Tier, parentFlow: KYCParentFlow)
}
