//
//  MultiBadgeCellModel.swift
//  PlatformUIKit
//
//  Created by Paulo on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift

public struct MultiBadgeCellModel {

    public let badgesRelay: BehaviorRelay<[BadgeAssetPresenting]> = .init(value: [])

    public var badges: Driver<[BadgeAssetPresenting]> {
        badgesRelay.asDriver()
    }
    
    public let layoutMarginsRelay: BehaviorRelay<UIEdgeInsets> = .init(
        value: .init(top: 24, left: 24, bottom: 24, right: 24)
    )

    public var layoutMargins: Driver<UIEdgeInsets> {
        layoutMarginsRelay.asDriver()
    }

    public init() { }
}
