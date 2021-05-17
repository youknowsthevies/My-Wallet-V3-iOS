// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

/// This implements an in-memory cache with transparent refreshing/invalidation
public class CachedValue<Value> {

    /// Any error produced internally
    private enum CachedValueError: Error {
        /// The fetch method is undefined
        case fetchMethodUndefined
    }

    /// Typealias for fetch method
    typealias FetchMethod = () -> Single<Value>

    @available(*, deprecated, message: "Do not use this! It is meant to support legacy code")
    public var legacyValue: Value? {
        atomicValue.value
    }

    /// Streams a single value and terminates
    public var valueSingle: Single<Value> {
        _ = setup
        return Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return self.fetch()
        }
    }

    /// Fetches the value and updates the cache for future subscribers.
    /// It streams the fetched value afterwards.
    public var fetchValue: Single<Value> {
        performFetchAndUpdateCache()
    }

    /// Invalidates the cache
    public var invalidate: Completable {
        _ = setup
        return Completable.create { [weak self] _ -> Disposable in
            self?.refreshControl.actionRelay.accept(.flush)
            return Disposables.create()
        }
    }

    /// Sets the fetch method. Must be called before any subscription.
    /// - Parameter fetch: The fetch method.
    public func setFetch(_ fetch: @escaping () -> Single<Value>) {
        self.fetchMethod = fetch
    }

    /// Sets the fetch method. Must be called before any subscription.
    /// - Parameters:
    ///   - object: Weakly refereced object
    ///   - fetch: Fetch method
    public func setFetch<A: AnyObject>(weak object: A, fetch: @escaping (A) -> Single<Value>) {
        self.fetchMethod = { [weak object] in
            guard let object = object else {
                return .error(ToolKitError.nullReference(A.self))
            }
            return fetch(object)
        }
    }

    private lazy var setup: Void = {
        refreshControl.action
            .do(onNext: { [weak self] action in

                guard let self = self else { return }

                switch action {
                case .fetch:
                    self.refresh()
                case .flush:
                    self.flush()
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
    }()

    private var fetchMethod: FetchMethod?

    private let atomicValue = Atomic<Value?>(nil)

    private let disposeBag = DisposeBag()

    private let configuration: CachedValueConfiguration
    private let refreshControl: CachedValueRefreshControl

    public convenience init() {
        self.init(configuration: CachedValueConfiguration())
    }

    public init(configuration: CachedValueConfiguration) {
        self.configuration = configuration
        refreshControl = CachedValueRefreshControl(configuration: configuration)
    }

    private func flush() {
        atomicValue.mutate { $0 = nil }
    }

    private func refresh() {
        performFetchAndUpdateCache()
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func fetch() -> Single<Value> {
        guard refreshControl.shouldRefresh else {
            guard let value = atomicValue.value else {
                return performFetchAndUpdateCache()
            }
            return .just(value)
        }
        return performFetchAndUpdateCache()
    }

    @discardableResult
    private func performFetchAndUpdateCache() -> Single<Value> {
        performFetch()
            .do(onSuccess: { [weak self] value in
                self?.refreshControl.update(refreshDate: Date())
                self?.atomicValue.mutate { $0 = value }
            })
            .observeOn(configuration.scheduler)
            .subscribeOn(configuration.scheduler)
    }

    private func performFetch() -> Single<Value> {
        guard let fetch = fetchMethod else {
            fatalError(CachedValueError.fetchMethodUndefined.localizedDescription)
        }
        return fetch()
    }
}

struct CachedValueRefreshControl {

    enum Action {

        case flush
        case fetch
    }

    var shouldRefresh: Bool {
        switch configuration.refreshType {
        case .onSubscription:
            return false
        case .periodic(let refreshInterval):
            let lastRefreshInterval = Date(timeIntervalSinceNow: -refreshInterval)
            let shouldRefresh = lastRefresh.value.compare(lastRefreshInterval) == .orderedAscending
            return shouldRefresh
        case .custom(let shouldRefresh):
            return shouldRefresh()
        }
    }

    var action: Observable<Action> {
        actionRelay.asObservable()
    }

    let actionRelay = PublishRelay<Action>()

    private let lastRefresh = Atomic<Date>(Date.distantPast)

    private let configuration: CachedValueConfiguration

    init() {
        self.init(
            configuration: CachedValueConfiguration()
        )
    }

    init(configuration: CachedValueConfiguration) {
        self.configuration = configuration

        if let notification = configuration.flushNotificationName {
            NotificationCenter.when(notification) { [weak actionRelay] _ in
                actionRelay?.accept(.flush)
            }
        }

        if let notification = configuration.fetchNotificationName {
            NotificationCenter.when(notification) { [weak actionRelay] _ in
                actionRelay?.accept(.fetch)
            }
        }
    }

    func update(refreshDate: Date) {
        lastRefresh.mutate { $0 = refreshDate }
    }

}

/// A configuration for cached value
public struct CachedValueConfiguration {

    /// A refresh type
    public enum RefreshType {

        /// Refresh once upon subscription
        case onSubscription

        /// Refresh periodically
        case periodic(seconds: TimeInterval)

        /// Custom configuration for refresh
        case custom(() -> Bool)
    }

    private static let defaultRefreshInterval: TimeInterval = 60 * 1

    let identifier: String?
    let refreshType: RefreshType
    let scheduler: SchedulerType
    let flushNotificationName: Notification.Name?
    let fetchNotificationName: Notification.Name?

    public init() {
        self.init(
            refreshType: .periodic(seconds: Self.defaultRefreshInterval)
        )
    }

    public init(identifier: String? = nil,
                refreshType: RefreshType,
                scheduler: SchedulerType = generateScheduler(),
                flushNotificationName: Notification.Name? = nil,
                fetchNotificationName: Notification.Name? = nil) {
        self.identifier = identifier
        self.refreshType = refreshType
        self.scheduler = scheduler
        self.flushNotificationName = flushNotificationName
        self.fetchNotificationName = fetchNotificationName
    }
}

extension CachedValueConfiguration {
    public static func generateScheduler() -> SchedulerType {
        SerialDispatchQueueScheduler(internalSerialQueueName: "internal-\(UUID().uuidString)")
    }
}
