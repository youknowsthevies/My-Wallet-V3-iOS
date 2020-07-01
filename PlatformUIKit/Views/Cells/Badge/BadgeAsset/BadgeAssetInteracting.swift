//
//  BadgeAssetInteracting.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public protocol BadgeAssetInteracting {
    var state: Observable<BadgeAsset.State.BadgeItem.Interaction> { get }
    var stateRelay: BehaviorRelay<BadgeAsset.State.BadgeItem.Interaction> { get }
}
