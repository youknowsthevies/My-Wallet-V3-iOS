//
//  MultiBadgeCellModel.swift
//  PlatformUIKit
//
//  Created by Paulo on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

public struct MultiBadgeViewModel {

    public let badgesRelay = BehaviorRelay<[BadgeAssetPresenting]>(value: [])
    public var badges: Driver<[BadgeAssetPresenting]> {
        badgesRelay.asDriver()
    }

    public let layoutMarginsRelay: BehaviorRelay<UIEdgeInsets>
    public var layoutMargins: Driver<UIEdgeInsets> {
        layoutMarginsRelay.asDriver()
    }

    public let heightRelay: BehaviorRelay<CGFloat>
    public var height: Driver<CGFloat> {
        heightRelay.asDriver()
    }

    public init(layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24),
                height: CGFloat = 32) {
        layoutMarginsRelay = BehaviorRelay<UIEdgeInsets>(value: layoutMargins)
        heightRelay = BehaviorRelay<CGFloat>(value: height)
    }
}
