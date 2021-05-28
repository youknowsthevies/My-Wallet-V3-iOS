// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxSwift

// TICKET: OS-4734 (remove this code)
public enum KYCParentFlow {
    case simpleBuy
    case none
}

// TICKET: IOS-4734 (remove this code)
public protocol KYCRouterAPI: class {
    var tier1Finished: Observable<Void> { get }
    var tier2Finished: Observable<Void> { get }
    var kycStopped: Observable<KYC.Tier> { get }
    func start()
    func start(tier: KYC.Tier)
    func start(from viewController: UIViewController, tier: KYC.Tier, parentFlow: KYCParentFlow)
}

public enum KYCRouterError: Error {
    case emailVerificationAbandoned
    case emailVerificationFailed
    case kycVerificationAbandoned
    case kycVerificationFailed
    case kycStepFailed
}

public protocol KYCRouting {
    func presentEmailVerificationAndKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError>
    func presentEmailVerificationIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError>
    func presentKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError>
}
