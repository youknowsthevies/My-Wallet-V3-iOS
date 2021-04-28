//
//  AnalyticsEventRecording.swift
//  PlatformKit
//
//  Created by Jack on 03/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay

public protocol AnalyticsEventRelayRecording {
    var recordRelay: PublishRelay<AnalyticsEvent> { get }
}

public protocol AnalyticsEventRecording: class {
    func record(event: AnalyticsEvent)
}
