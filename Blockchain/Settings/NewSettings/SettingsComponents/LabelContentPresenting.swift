//
//  SettingsAsset.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

protocol LabelContentPresenting {
    var stateRelay: BehaviorRelay<LabelContentAsset.State.LabelItem.Presentation> { get }
    var state: Observable<LabelContentAsset.State.LabelItem.Presentation> { get }
}

protocol LabelContentInteracting {
    var stateRelay: BehaviorRelay<LabelContentAsset.State.LabelItem.Interaction> { get }
    var state: Observable<LabelContentAsset.State.LabelItem.Interaction> { get }
}
