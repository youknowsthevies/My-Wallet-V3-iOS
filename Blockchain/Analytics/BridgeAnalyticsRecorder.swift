// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import ToolKit

@objc protocol ObjcAnalyticsEvent {
    var name: String { get }
    var params: [String: String]? { get }
}

// Obj-C Bridge to AnalyticsEventRecording. Deprecate this once obj-c callers are updated to Swift
@objc class BridgeAnalyticsRecorder : NSObject {

    private let recorder: AnalyticsServiceProviding

    override init() {
        self.recorder = resolve()
        super.init()
    }

    @objc public func record(event: ObjcAnalyticsEvent) {
        recorder.trackEvent(title: event.name, parameters: event.params)
    }
}
