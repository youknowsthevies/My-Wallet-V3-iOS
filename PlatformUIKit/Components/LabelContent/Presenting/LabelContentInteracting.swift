//
//  LabelContentInteracting.swift
//  PlatformUIKit
//
//  Created by Paulo on 01/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

public protocol LabelContentInteracting {
    var stateRelay: BehaviorRelay<LabelContent.State.Interaction> { get }
    var state: Observable<LabelContent.State.Interaction> { get }
}
