//
//  BeneficiariesService.swift
//  BuySellKit
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay
import ToolKit

public protocol BeneficiariesServiceAPI: PaymentMethodDeletionServiceAPI {
    
    /// Streams the beneficiaries
    var beneficiaries: Observable<[Beneficiary]> { get }
    
    /// Keeps updating a new value of whether the user has at least one linked bank
    var hasLinkedBank: Observable<Bool> { get }
    
    /// Fetch beneficiaries once, but other subscribers to `beneficiaries` would get the new value
    func fetch() -> Observable<[Beneficiary]>
}

final class BeneficiariesService: BeneficiariesServiceAPI {

    // MARK: - Properties
    
    public var beneficiaries: Observable<[Beneficiary]> {
        beneficiariesRelay
            .flatMap(weak: self) { (self, beneficiaries) -> Observable<[Beneficiary]> in
                guard let beneficiaries = beneficiaries else {
                    return self.fetch().asObservable()
                }
                return .just(beneficiaries)
            }
            .distinctUntilChanged()
    }
        
    var hasLinkedBank: Observable<Bool> {
        beneficiaries.map { !$0.isEmpty }
    }

    private let beneficiariesRelay = BehaviorRelay<[Beneficiary]?>(value: nil)
    private let featureFetcher: FeatureFetching
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let client: BeneficiariesClientAPI
        
    // MARK: - Setup
    
    init(client: BeneficiariesClientAPI,
         featureFetcher: FeatureFetching,
         paymentMethodTypesService: PaymentMethodTypesServiceAPI) {
        self.client = client
        self.featureFetcher = featureFetcher
        self.paymentMethodTypesService = paymentMethodTypesService
    }
    
    func fetch() -> Observable<[Beneficiary]> {
        performFetch()
            .do(onNext: { [weak self] beneficiaries in
                self?.beneficiariesRelay.accept(beneficiaries)
            })
    }
    
    func delete(by bankId: String) -> Completable {
        client.deleteBank(by: bankId)
            .andThen(self.fetch())
            .ignoreElements()
    }
    
    // MARK: - Private
        
    private func performFetch() -> Observable<[Beneficiary]> {
        Observable
            .combineLatest(
                client.beneficiaries.asObservable(),
                paymentMethodTypesService.methodTypes.map { $0.accounts.map { $0.topLimit } },
                featureFetcher.fetchBool(for: .simpleBuyFundsEnabled).asObservable()
            )
            .map { (beneficiaries: [BeneficiaryResponse], topLimits: [FiatValue], isEnabled: Bool) in
                guard isEnabled else { return [] }
                var limitsByBaseFiat: [FiatCurrency : FiatValue] = [:]
                for limit in topLimits {
                    limitsByBaseFiat[limit.currencyType] = limit
                }
                let result: [Beneficiary] = beneficiaries.compactMap {
                    guard let currency = FiatCurrency(code: $0.currency) else { return nil }
                    return Beneficiary(response: $0, limit: limitsByBaseFiat[currency])
                }
                return result
            }
            .catchErrorJustReturn([])
    }
}
