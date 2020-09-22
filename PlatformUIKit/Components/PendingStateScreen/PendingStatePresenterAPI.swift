//
//  PendingStatePresenterAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 21/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

public protocol PendingStatePresenterAPI: class {
    var title: String { get }
    var viewModel: Driver<PendingStateViewModel> { get }
    var pendingStatusViewEdgeSize: CGFloat { get }
    var pendingStatusViewSideContainerRatio: CGFloat { get }
}

extension PendingStatePresenterAPI {
    public var title: String { "" }
    public var pendingStatusViewSideContainerRatio: CGFloat { 0.35 }
    public var pendingStatusViewEdgeSize: CGFloat { 80 }
}
