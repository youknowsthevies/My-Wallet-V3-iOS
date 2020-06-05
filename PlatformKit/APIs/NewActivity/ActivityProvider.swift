//
//  ActivityProvider.swift
//  PlatformKit
//
//  Created by Alex McGregor on 5/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol ActivityProviding: class {
    /// Returns the activity service
    subscript(currency: CryptoCurrency) -> ActivityItemEventServiceAPI { get }
    
    var swapActivityItems: Observable<LoadingState<[SwapActivityItemEvent]>> { get }
    var activityItems: Observable<ActivityItemEventsLoadingState> { get }
    var transactionalActivityItems: Observable<ActivityItemEventsLoadingStates> { get }
    
    func refresh()
}

public final class ActivityProvider: ActivityProviding {
    
    // MARK: - Public Properties
    
    public subscript(currency: CryptoCurrency) -> ActivityItemEventServiceAPI {
        services[currency]!
    }
    
    public var swapActivityItems: Observable<LoadingState<[SwapActivityItemEvent]>> {
        swapActivityAPI
            .fetchActivity(from: Date())
            .asObservable()
            .catchErrorJustReturn([])
            .map { .loaded(next: $0) }
            .startWith(.loading)
    }
    
    public var transactionalActivityItems: Observable<ActivityItemEventsLoadingStates> {
        Observable.combineLatest(
            services[.ethereum]!.transactionActivityObservable,
            services[.pax]!.transactionActivityObservable,
            services[.stellar]!.transactionActivityObservable,
            services[.bitcoin]!.transactionActivityObservable,
            services[.bitcoinCash]!.transactionActivityObservable
        )
        .map {
            ActivityItemEventsLoadingStates(
                statePerCurrency: [
                    .ethereum: $0.0,
                    .pax: $0.1,
                    .stellar: $0.2,
                    .bitcoin: $0.3,
                    .bitcoinCash: $0.4
                ]
            )
        }
        .share()
    }
    
    public var activityItems: Observable<ActivityItemEventsLoadingState> {
        let transactions = transactionalActivityItems.map { $0.allActivity }
        return Observable.combineLatest(
            transactions,
            swapActivityItems
        )
        .map(weak: self) { (self, states) -> ActivityItemEventsLoadingState in
            self.reduce(swapsState: states.1, transactionsState: states.0)
        }
    }
    
    // MARK: - Private Properties
    
    private var activityItemsLoadingStates: Observable<ActivityItemEventsLoadingStates> {
        Observable.combineLatest(
            services[.ethereum]!.activityLoadingStateObservable,
            services[.pax]!.activityLoadingStateObservable,
            services[.stellar]!.activityLoadingStateObservable,
            services[.bitcoin]!.activityLoadingStateObservable,
            services[.bitcoinCash]!.activityLoadingStateObservable
        )
        .map {
            ActivityItemEventsLoadingStates(
                statePerCurrency: [
                    .ethereum: $0.0,
                    .pax: $0.1,
                    .stellar: $0.2,
                    .bitcoin: $0.3,
                    .bitcoinCash: $0.4
                ]
            )
        }
        .share()
    }
    
    // MARK: - Services
    
    private var services: [CryptoCurrency: ActivityItemEventServiceAPI] = [:]
    private let swapActivityAPI: SwapActivityServiceAPI
    
    // MARK: - Setup
    
    public init(ether: ActivityItemEventServiceAPI,
                pax: ActivityItemEventServiceAPI,
                stellar: ActivityItemEventServiceAPI,
                bitcoin: ActivityItemEventServiceAPI,
                bitcoinCash: ActivityItemEventServiceAPI,
                authenticationService: NabuAuthenticationServiceAPI,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        services[.ethereum] = ether
        services[.pax] = pax
        services[.stellar] = stellar
        services[.bitcoin] = bitcoin
        services[.bitcoinCash] = bitcoinCash
        swapActivityAPI = SwapActivityService(
            authenticationService: authenticationService,
            fiatCurrencyProvider: fiatCurrencyService
        )
    }
    
    // MARK: - Public Functions
    
    public func refresh() {
        services.values.forEach { $0.fetchTriggerRelay.accept(()) }
    }
    
    // MARK: - Private Functions
    
    private func reduce(swapsState: LoadingState<[SwapActivityItemEvent]>,
                        transactionsState: LoadingState<[ActivityItemEvent]>) -> ActivityItemEventsLoadingState {
        guard !swapsState.isLoading && !transactionsState.isLoading else {
            return .loading
        }
        guard
            let swaps = swapsState.value,
            let transactions = transactionsState.value
            else {
                return .loading
            }
        let values: [ActivityItemEvent] = swaps.map { .swap($0) } + transactions
        return .loaded(next: values)
    }
}
