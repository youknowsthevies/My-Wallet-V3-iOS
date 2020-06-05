//
//  BadgeAssetPresenting.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public protocol BadgeAssetPresenting {
    var state: Observable<BadgeAsset.State.BadgeItem.Presentation> { get }
}
