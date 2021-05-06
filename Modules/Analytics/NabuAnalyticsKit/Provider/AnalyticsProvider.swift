// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import AnalyticsKit
import DIKit

class AnalyticsProvider: AnalyticsServiceProviding {
    public var supportedEventTypes: [AnalyticsEventType] = [.new]
    
    private let nabuAnalyticsClient: EventSendingAPI
    private let contextProvider: ContextProviding
    
    init(nabuAnalyticsClient: EventSendingAPI = resolve(),
         contextProvider: ContextProviding = resolve()) {
        self.nabuAnalyticsClient = nabuAnalyticsClient
        self.contextProvider = contextProvider
    }
    
    func trackEvent(title: String, parameters: [String : Any]?) {
        let event = Event(originalTimestamp: Date(),
                          name: title,
                          type: .event,
                          properties: nil)
        let context = contextProvider.context
        let eventsWrapper = EventsWrapper(id: UUID().uuidString, context: context, events: [event])
        nabuAnalyticsClient.post(events: eventsWrapper)
    }
}
