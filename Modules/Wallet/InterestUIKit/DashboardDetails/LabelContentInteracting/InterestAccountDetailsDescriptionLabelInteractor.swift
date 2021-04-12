//
//  InterestAccountDetailsDescriptionLabelInteractor.swift
//  InterestUIKit
//
//  Created by Alex McGregor on 8/11/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import InterestKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class InterestAccountDetailsDescriptionLabelInteractor {
    
    typealias InteractionState = LabelContent.State.Interaction
    typealias LocalizationId = LocalizationConstants.Interest.Screen.AccountDetails
    
    final class TotalInterest: LabelContentInteracting {
        
        private lazy var setup: Void = {
            service
                .details(for: cryptoCurrency)
                .asObservable()
                .map { $0.value }
                .compactMap { $0?.totalInterest }
                .compactMap { CryptoValue.create(minor: $0, currency: self.cryptoCurrency) }
                .map { $0.toDisplayString(includeSymbol: true) }
                .map { .loaded(next: .init(text: $0)) }
                .bindAndCatch(to: stateRelay)
                .disposed(by: disposeBag)
        }()
        
        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }
        
        // MARK: - Private Properties
        
        private let service: SavingAccountServiceAPI
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()
        
        // MARK: - Private Accessors
        
        init(service: SavingAccountServiceAPI,
             cryptoCurrency: CryptoCurrency) {
            self.service = service
            self.cryptoCurrency = cryptoCurrency
        }
    }
    
    final class PendingDeposit: LabelContentInteracting {
        
        private lazy var setup: Void = {
            service
                .details(for: cryptoCurrency)
                .asObservable()
                .map { $0.value }
                .compactMap { $0?.pendingInterest }
                .compactMap { CryptoValue.create(minor: $0, currency: self.cryptoCurrency) }
                .map { $0.toDisplayString(includeSymbol: true) }
                .map { .loaded(next: .init(text: $0)) }
                .bindAndCatch(to: stateRelay)
                .disposed(by: disposeBag)
        }()
        
        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }
        
        // MARK: - Private Properties
        
        private let service: SavingAccountServiceAPI
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()
        
        // MARK: - Private Accessors
        
        init(service: SavingAccountServiceAPI,
             cryptoCurrency: CryptoCurrency) {
            self.service = service
            self.cryptoCurrency = cryptoCurrency
        }
    }
    
    final class LockUpDuration: LabelContentInteracting {
        
        private lazy var setup: Void = {
            service
                .limits(for: cryptoCurrency)
                .asObservable()
                .map { $0.value }
                .compactMap { $0?.lockupDescription }
                .map { .loaded(next: .init(text: $0)) }
                .bindAndCatch(to: stateRelay)
                .disposed(by: disposeBag)
        }()
        
        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }
        
        // MARK: - Private Properties
        
        private let service: SavingAccountServiceAPI
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()
        
        // MARK: - Private Accessors
        
        init(service: SavingAccountServiceAPI,
             cryptoCurrency: CryptoCurrency) {
            self.service = service
            self.cryptoCurrency = cryptoCurrency
        }
    }
    
    final class Rates: LabelContentInteracting {
        
        private lazy var setup: Void = {
            service
                .rate(for: cryptoCurrency)
                .asObservable()
                .compactMap { "\($0)% \(LocalizationId.annually)" }
                .map { .loaded(next: .init(text: $0)) }
                .catchErrorJustReturn(.loading)
                .bindAndCatch(to: stateRelay)
                .disposed(by: disposeBag)
        }()
        
        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }
        
        // MARK: - Private Properties
        
        private let service: SavingAccountServiceAPI
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()
        
        // MARK: - Private Accessors
        
        init(service: SavingAccountServiceAPI,
             cryptoCurrency: CryptoCurrency) {
            self.service = service
            self.cryptoCurrency = cryptoCurrency
        }
    }
    
    final class NextPayment: LabelContentInteracting {
        
        private lazy var setup: Void = {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            components.day = 1
            let month = components.month ?? 0
            components.month = month + 1
            components.calendar = .current
            let next = components.date ?? Date()
            Observable.just(DateFormatter.long.string(from: next))
                .map { .loaded(next: .init(text: $0)) }
                .bindAndCatch(to: stateRelay)
                .disposed(by: disposeBag)
        }()
        
        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }
        
        // MARK: - Private Properties
        
        private let date: Date
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()
        
        // MARK: - Private Accessors
        
        init(date: Date = Date(),
             cryptoCurrency: CryptoCurrency) {
            self.date = date
            self.cryptoCurrency = cryptoCurrency
        }
    }
}
