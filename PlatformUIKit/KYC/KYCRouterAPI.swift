//
//  KYCRouterAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
    func start(from viewController: UIViewController, tier: KYC.Tier, parentFlow: KYCParentFlow)
}
