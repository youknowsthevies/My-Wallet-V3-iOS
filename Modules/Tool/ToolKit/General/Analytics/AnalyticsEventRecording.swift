//
//  AnalyticsEventRecording.swift
//  PlatformKit
//
//  Created by Jack on 03/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay

public protocol AnalyticsEvent {
    var name: String { get }
    var params: [String: String]? { get }
}

extension AnalyticsEvent {
    public var params: [String: String]? { nil }
}

public protocol AnalyticsEventRelayRecording {
    var recordRelay: PublishRelay<AnalyticsEvent> { get }
}

public protocol AnalyticsEventRecording: AnyObject {
    func record(event: AnalyticsEvent)
}

/// Class that can be extended with nested types of events
public class AnalyticsEvents {}
