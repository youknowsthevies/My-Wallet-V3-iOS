// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import CombineExt
import DIKit
import Foundation

public class AnalyticsProvider: AnalyticsServiceProviding {

    private enum Constants {
        static let batchSize = 20
        static let updateRate: TimeInterval = 30
    }

    public var supportedEventTypes: [AnalyticsEventType] = [.new]

    @LazyInject private var nabuAnalyticsService: AnalyticsEventServiceAPI
    @LazyInject private var contextProvider: ContextProviderAPI

    private let fileCache = FileCache()

    private var cancellables = Set<AnyCancellable>()

    @Published private var events = [Event]()

    public init(queue: DispatchQueue = DispatchQueue(label: "NabuAnalyticsProvider", qos: .background)) {

        let updateRateTimer = Timer
            .publish(every: Constants.updateRate, on: .main, in: .default)
            .autoconnect()
            .receive(on: queue)
            .withLatestFrom($events)

        let batchFull = $events
            .filter { $0.count >= Constants.batchSize }
            .receive(on: queue)

        let enteredBackground = NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: queue)
            .withLatestFrom($events)

        updateRateTimer
            .merge(with: batchFull)
            .merge(with: enteredBackground)
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .sink(receiveValue: send)
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: queue)
            .compactMap { _ in self.fileCache.read() }
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .sink(receiveValue: send)
            .store(in: &cancellables)
    }

    public func trackEvent(title: String, parameters: [String: Any]?) {
        events.append(Event(title: title, properties: parameters))
    }

    private func send(events: [Event]) {
        self.events = self.events.filter { !events.contains($0) }
        nabuAnalyticsService.publish(events: EventsWrapper(contextProvider: contextProvider, events: events))
            .sink() { [unowned self] _ in
                self.fileCache.save(events: events)
            } receiveValue: { _ in /* NOOP */ }
            .store(in: &cancellables)
    }
}
