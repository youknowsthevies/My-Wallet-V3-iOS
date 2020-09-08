//
//  CheckoutSelectionAPI.swift
//  BuySellUIKit
//
//  Created by Alex McGregor on 8/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformUIKit
import RxRelay
import ToolKit

public enum CheckoutDataAction {
    case cancel(CheckoutData)
    case bankTransferDetails(CheckoutData)
    case confirm(CheckoutData, isOrderNew: Bool)
}

public protocol CheckoutSelectionAPI {
    var actionRelay: PublishRelay<CheckoutDataAction> { get }
    var analyticsRecorder: AnalyticsEventRecorderAPI { get }
}

public typealias CheckoutRoutingInteracting = CheckoutSelectionAPI & RoutingPreviousStateEmitterAPI
