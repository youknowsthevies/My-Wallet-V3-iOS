//
//  ActivityItemEventsLoadingStates.swift
//  PlatformKit
//
//  Created by Alex McGregor on 5/7/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public typealias ActivityItemEventsLoadingState = LoadingState<[ActivityItemEvent]>

/// This construct provides access to aggregated `[ActivityItemEvent]` states
/// Any supported asset balance should be accessible here.
public struct ActivityItemEventsLoadingStates {
    
    // MARK: - Properties
        
    /// Returns `ActivityItemEventsLoadingState` for a given `CryptoCurrency`
    public subscript(currencyType: CurrencyType) -> ActivityItemEventsLoadingState {
        statePerCurrency[currencyType]!
    }
    
    /// Returns all the states
    public var all: [ActivityItemEventsLoadingState] {
        Array(statePerCurrency.values)
    }
    
    /// All elements must be `.loading` for that to return `true`
    public var isLoading: Bool {
        !all.contains { !$0.isLoading }
    }
    
    /// Returns the total fiat calcuation state
    public var allActivity: ActivityItemEventsLoadingState {
        guard !isLoading else {
            return .loading
        }
        let values: [ActivityItemEvent] = all.compactMap { $0.value }
            .flatMap { $0 }
            .unique
        return .loaded(next: values)
    }
    
    // MARK: - Private Properties
    
    private var statePerCurrency: [CurrencyType: ActivityItemEventsLoadingState] = [:]
    
    // MARK: - Setup
    
    public init(statePerCurrency: [CurrencyType: ActivityItemEventsLoadingState]) {
        self.statePerCurrency = statePerCurrency
    }
}

extension Array where Element == ActivityItemEventsLoadingState {
    public func reduce() -> ActivityItemEventsLoadingState {
        guard !self.contains(where: { $0.isLoading }) else { return .loading }
        let items = self.compactMap { $0.value }
        guard items.count == count else { return .loading }
        let values = items.flatMap { $0 }
        return .loaded(next: values)
    }
}
