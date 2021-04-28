//
//  AnalyticsServiceAPI.swift
//  PlatformKit
//
//  Created by Jack on 03/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol AnalyticsServiceProviding {

    func trackEvent(title: String)

    func trackEvent(title: String, parameters: [String: Any]?)
    
    var supportedEventTypes: [AnalyticsEventType] { get }
}

extension AnalyticsServiceProviding {
    
    public var supportedEventTypes: [AnalyticsEventType] {
        [.old]
    }
    
    public func trackEvent(title: String) {
        trackEvent(title: title, parameters: nil)
    }
    
    func isEventSupported(_ event: AnalyticsEvent) -> Bool {
        supportedEventTypes.contains(event.type)
    }
}
