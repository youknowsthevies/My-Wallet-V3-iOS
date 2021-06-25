// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit
import Combine
import Foundation

public final class NabuAnalyticsProvider: AnalyticsServiceProviderAPI {

    public var supportedEventTypes: [AnalyticsEventType] = [.nabu]

    private enum Constants {
        static let batchSize = 20
        static let updateLatency: TimeInterval = 30
    }

    private let fileCache: FileCacheAPI
    private let platform: Platform
    private let eventsRepository: NabuAnalyticsEventsRepositoryAPI
    private let contextProvider: ContextProviderAPI

    private var cancellables = Set<AnyCancellable>()

    @Published private var events = [Event]()

    public convenience init(platform: Platform,
                            basePath: String,
                            userAgent: String,
                            tokenRepository: TokenRepositoryAPI,
                            guidProvider: GuidProviderAPI) {
        self.init(platform: platform,
                  eventsRepository: NabuAnalyticsEventsRepository(client: APIClient(basePath: basePath, userAgent: userAgent),
                                                                  tokenRepository: tokenRepository),
                  contextProvider: ContextProvider(guidProvider: guidProvider))
    }

    let queue: DispatchQueue = DispatchQueue(label: "AnalyticsKit", qos: .background)

    init(fileCache: FileCacheAPI = FileCache(),
         platform: Platform,
         eventsRepository: NabuAnalyticsEventsRepositoryAPI,
         contextProvider: ContextProviderAPI) {

        self.fileCache = fileCache
        self.platform = platform
        self.eventsRepository = eventsRepository
        self.contextProvider = contextProvider

        queue.async { [unowned self] in
            let updateRateTimer = Timer
                .publish(every: Constants.updateLatency, on: .current, in: .default)
                .autoconnect()
                .withLatestFrom($events)

            let batchFull = $events
                .filter { $0.count >= Constants.batchSize }

            let enteredBackground = NotificationCenter.default
                .publisher(for: UIApplication.willResignActiveNotification)
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
                .compactMap { [fileCache] _ in fileCache.read() }
                .filter { !$0.isEmpty }
                .removeDuplicates()
                .sink(receiveValue: send)
                .store(in: &cancellables)

            NotificationCenter.default
                .publisher(for: UIApplication.willTerminateNotification)
                .withLatestFrom($events)
                .sink(receiveValue: fileCache.save)
                .store(in: &cancellables)
        }
    }

    public func trackEvent(title: String, parameters: [String: Any]?) {
        queue.async { [unowned self] in
            events.append(Event(title: title, properties: parameters))
        }
    }

    private func send(events: [Event]) {
        self.events = self.events.filter { !events.contains($0) }
        eventsRepository.publish(events: EventsWrapper(contextProvider: contextProvider, events: events, platform: platform))
            .sink() { [fileCache] completion in
                if case let .failure(error) = completion {
                    if (500...599).contains(error.errorCode) || error.networkUnavailableReason != nil {
                        fileCache.save(events: events)
                    }
                }
            } receiveValue: { _ in /* NOOP */ }
            .store(in: &cancellables)
    }
}
