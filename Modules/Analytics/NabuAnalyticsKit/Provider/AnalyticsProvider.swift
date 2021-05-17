// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Foundation

public class AnalyticsProvider: AnalyticsServiceProviding {
    public var supportedEventTypes: [AnalyticsEventType] = [.new]
    
    @LazyInject private var nabuAnalyticsClient: EventSendingAPI
    @LazyInject private var contextProvider: ContextProviding
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() { }
    
    public func trackEvent(title: String, parameters: [String: Any]?) {
        let event = Event(title: title, properties: parameters)
        // TODO: IOS-4556 - batching
        let eventsWrapper = EventsWrapper(contextProvider: contextProvider, events: [event])
        nabuAnalyticsClient.publish(events: eventsWrapper)
            .retry(Constant.retryCount)
            .sink() { (error) in
                print(error) // TODO: IOS-4556 - persistence
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private enum Constant {
        static let retryCount = 3
    }
}
