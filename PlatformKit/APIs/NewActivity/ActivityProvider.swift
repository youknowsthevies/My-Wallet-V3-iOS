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
    
    var buyActivityItems: Observable<ActivityItemEventsLoadingStates> { get }
    var swapActivityItems: Observable<ActivityItemEventsLoadingStates> { get }
    var activityItems: Observable<ActivityItemEventsLoadingState> { get }
    var transactionalActivityItems: Observable<ActivityItemEventsLoadingStates> { get }
    
    func refresh()
}

public final class ActivityProvider: ActivityProviding {
    
    // MARK: - Public Properties
    
    public subscript(currency: CryptoCurrency) -> ActivityItemEventServiceAPI {
        services[currency]!
    }
    
    // MARK: - Services
    
    private var services: [CryptoCurrency: ActivityItemEventServiceAPI] = [:]
    
    // MARK: - Setup
    
    public init(algorand: ActivityItemEventServiceAPI,
                ether: ActivityItemEventServiceAPI,
                pax: ActivityItemEventServiceAPI,
                stellar: ActivityItemEventServiceAPI,
                bitcoin: ActivityItemEventServiceAPI,
                bitcoinCash: ActivityItemEventServiceAPI,
                tether: ActivityItemEventServiceAPI) {
        services[.algorand] = algorand
        services[.ethereum] = ether
        services[.pax] = pax
        services[.stellar] = stellar
        services[.bitcoin] = bitcoin
        services[.bitcoinCash] = bitcoinCash
        services[.tether] = tether
    }
    
    public var buyActivityItems: Observable<ActivityItemEventsLoadingStates> {
        Observable.combineLatest(
            services[.ethereum]!.buy.state,
            services[.pax]!.buy.state,
            services[.stellar]!.buy.state,
            services[.bitcoin]!.buy.state,
            services[.bitcoinCash]!.buy.state,
            services[.algorand]!.buy.state,
            services[.tether]!.buy.state
        ) { (ethereum: $0, pax: $1, stellar: $2, bitcoin: $3, bitcoinCash: $4, algorand: $5, tether: $6) }
        .map { states in
            ActivityItemEventsLoadingStates(
                statePerCurrency: [
                    .ethereum: states.ethereum,
                    .pax: states.pax,
                    .stellar: states.stellar,
                    .bitcoin: states.bitcoin,
                    .bitcoinCash: states.bitcoinCash,
                    .algorand: states.algorand,
                    .tether: states.tether
                ]
            )
        }
        .share()
    }
    
    public var swapActivityItems: Observable<ActivityItemEventsLoadingStates> {
        Observable.combineLatest(
            services[.ethereum]!.swap.state,
            services[.pax]!.swap.state,
            services[.stellar]!.swap.state,
            services[.bitcoin]!.swap.state,
            services[.bitcoinCash]!.swap.state
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
    
    public var transactionalActivityItems: Observable<ActivityItemEventsLoadingStates> {
        Observable.combineLatest(
            services[.ethereum]!.transactional.state,
            services[.pax]!.transactional.state,
            services[.stellar]!.transactional.state,
            services[.bitcoin]!.transactional.state,
            services[.bitcoinCash]!.transactional.state
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
        activityItemsLoadingStates.map { $0.allActivity }
    }
    
    public func refresh() {
        services.values.forEach { $0.refresh() }
    }
    
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
}
