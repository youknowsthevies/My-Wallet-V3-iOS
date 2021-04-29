//
//  TransferOrderRoutingInteracting.swift
//  BuySellUIKit
//
//  Created by Alex McGregor on 8/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import PlatformUIKit

public protocol TransferOrderRoutingInteracting: RoutingNextStateEmitterAPI, RoutingPreviousStateEmitterAPI {
    var analyticsRecorder: AnalyticsEventRecording { get }
}
