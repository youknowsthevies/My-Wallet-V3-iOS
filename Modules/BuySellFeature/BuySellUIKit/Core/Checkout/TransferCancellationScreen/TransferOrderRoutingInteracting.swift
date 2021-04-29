// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformUIKit

public protocol TransferOrderRoutingInteracting: RoutingNextStateEmitterAPI, RoutingPreviousStateEmitterAPI {
    var analyticsRecorder: AnalyticsEventRecording { get }
}
