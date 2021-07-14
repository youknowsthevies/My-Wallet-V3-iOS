// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
import Foundation
import UIKit

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
    private let queue: DispatchQueue = DispatchQueue(label: "AnalyticsKit", qos: .background)
    private var cancellables = Set<AnyCancellable>()

    @Published private var events = [Event]()

    public convenience init(platform: Platform,
                            basePath: String,
                            userAgent: String,
                            tokenRepository: TokenRepositoryAPI,
                            guidProvider: GuidRepositoryAPI) {
        let client = APIClient(basePath: basePath, userAgent: userAgent)
        let eventsRepository = NabuAnalyticsEventsRepository(client: client, tokenRepository: tokenRepository)
        let contextProvider = ContextProvider(guidProvider: guidProvider)
        self.init(platform: platform,
                  eventsRepository: eventsRepository,
                  contextProvider: contextProvider)
    }

    init(fileCache: FileCacheAPI = FileCache(),
         platform: Platform,
         eventsRepository: NabuAnalyticsEventsRepositoryAPI,
         contextProvider: ContextProviderAPI) {

        self.fileCache = fileCache
        self.platform = platform
        self.eventsRepository = eventsRepository
        self.contextProvider = contextProvider

        setupBatching()
    }

    private func setupBatching() {
        queue.async { [weak self] in
            guard let self = self else { return }
            let updateRateTimer = Timer
                .publish(every: Constants.updateLatency, on: .current, in: .default)
                .autoconnect()
                .withLatestFrom(self.$events)

            let batchFull = self.$events
                .filter { $0.count >= Constants.batchSize }

            let enteredBackground = NotificationCenter.default
                .publisher(for: UIApplication.willResignActiveNotification)
                .withLatestFrom(self.$events)

            updateRateTimer
                .merge(with: batchFull)
                .merge(with: enteredBackground)
                .filter { !$0.isEmpty }
                .removeDuplicates()
                .sink(receiveValue: self.send)
                .store(in: &self.cancellables)

            NotificationCenter.default
                .publisher(for: UIApplication.willEnterForegroundNotification)
                .receive(on: self.queue)
                .compactMap { _ in self.fileCache.read() }
                .filter { !$0.isEmpty }
                .removeDuplicates()
                .sink(receiveValue: self.send)
                .store(in: &self.cancellables)

            NotificationCenter.default
                .publisher(for: UIApplication.willTerminateNotification)
                .withLatestFrom(self.$events)
                .sink(receiveValue: self.fileCache.save)
                .store(in: &self.cancellables)
        }
    }

    public func trackEvent(title: String, parameters: [String: Any]?) {
        queue.async { [weak self] in
            self?.events.append(Event(title: title, properties: parameters))
        }
    }

    private func send(events: [Event]) {
        self.events = self.events.filter { !events.contains($0) }
        let eventsWrapper = EventsWrapper(contextProvider: contextProvider, events: events, platform: platform)
        eventsRepository.publish(events: eventsWrapper)
            .sink() { [fileCache] completion in
                if case let .failure(error) = completion {
                    if (500...599).contains(error.errorCode) || error.networkUnavailableReason != nil {
                        fileCache.save(events: events)
                    }
                }
            } receiveValue: { _ in
                /* NOOP */
            }
            .store(in: &cancellables)
    }
}
