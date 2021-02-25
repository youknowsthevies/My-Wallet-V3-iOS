//
//  BeneficiariesService.swift
//  BuySellKit
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol BeneficiariesServiceAPI: PaymentMethodDeletionServiceAPI {
    
    /// Streams the beneficiaries
    var beneficiaries: Observable<[Beneficiary]> { get }
    
    /// Keeps updating a new value of whether the user has at least one linked bank
    var hasLinkedBank: Observable<Bool> { get }
    
    /// Streams the available currencies for bank linkage
    var availableCurrenciesForBankLinkage: Observable<Set<FiatCurrency>> { get }
    
    /// Fetch beneficiaries once, but other subscribers to `beneficiaries` would get the new value
    func fetch() -> Observable<[Beneficiary]>
}

final class BeneficiariesService: BeneficiariesServiceAPI {

    // MARK: - Properties
    
    public var beneficiaries: Observable<[Beneficiary]>

    public let hasLinkedBank: Observable<Bool>

    let availableCurrenciesForBankLinkage: Observable<Set<FiatCurrency>>

    private let fetchBeneficiaries: Observable<[Beneficiary]>

    private let beneficiariesRelay = BehaviorRelay<[Beneficiary]?>(value: nil)
    private let featureFetcher: FeatureFetching
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let client: BeneficiariesClientAPI
    private let linkedBankClient: LinkedBanksClientAPI
        
    // MARK: - Setup
    
    init(client: BeneficiariesClientAPI = resolve(),
         linkedBankClient: LinkedBanksClientAPI = resolve(),
         featureFetcher: FeatureFetching = resolve(),
         paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve()) {
        self.client = client
        self.linkedBankClient = linkedBankClient
        self.featureFetcher = featureFetcher
        self.paymentMethodTypesService = paymentMethodTypesService
        
        NotificationCenter.when(.logout) { [weak beneficiariesRelay] _ in
            beneficiariesRelay?.accept(nil)
        }

        let fetchBeneficiaries: Observable<[Beneficiary]> = Observable
            .combineLatest(
                client.beneficiaries.asObservable(),
                paymentMethodTypesService.methodTypes,
                featureFetcher.fetchBool(for: .simpleBuyFundsEnabled).asObservable()
            )
            .map { (beneficiaries: [BeneficiaryResponse], methodTypes: [PaymentMethodType], isEnabled: Bool) in
                guard isEnabled else { return [] }
                var limitsByBaseFiat: [FiatCurrency : FiatValue] = [:]
                let topLimits = methodTypes.accounts.map { $0.topLimit }
                for limit in topLimits {
                    limitsByBaseFiat[limit.currencyType] = limit
                }
                let activeLinkedBank = methodTypes.linkedBanks
                    .filter { $0.isActive }

                let linkedBanksResult: [Beneficiary] = activeLinkedBank.map(Beneficiary.init(linkedBankData:))

                let result: [Beneficiary] = beneficiaries.compactMap {
                    guard let currency = FiatCurrency(code: $0.currency) else { return nil }
                    return Beneficiary(response: $0, limit: limitsByBaseFiat[currency])
                }
                return result + linkedBanksResult
            }
            .do(afterNext: { [weak beneficiariesRelay] beneficiaries in
                beneficiariesRelay?.accept(beneficiaries)
            })
            .catchErrorJustReturn([])
            .share()

        self.fetchBeneficiaries = fetchBeneficiaries

        beneficiaries = beneficiariesRelay
            .flatMap { (beneficiaries) -> Observable<[Beneficiary]> in
                guard let beneficiaries = beneficiaries else {
                    return fetchBeneficiaries.asObservable()
                }
                return .just(beneficiaries)
            }
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)

        availableCurrenciesForBankLinkage = paymentMethodTypesService.methodTypes
            .map { (methodTypes) in
                Set(methodTypes.suggestedFunds)
            }
            .share(replay: 1, scope: .whileConnected)

        hasLinkedBank = beneficiaries
            .map { !$0.isEmpty }
    }
    
    func fetch() -> Observable<[Beneficiary]> {
        performFetch()
            .do(onNext: { [weak self] beneficiaries in
                self?.beneficiariesRelay.accept(beneficiaries)
            })
    }
    
    func delete(by bankId: String) -> Completable {
        client.deleteBank(by: bankId)
            .andThen(self.fetchBeneficiaries)
            .ignoreElements()
    }
        
    // MARK: - Private
        
    private func performFetch() -> Observable<[Beneficiary]> {
        Observable
            .combineLatest(
                client.beneficiaries.asObservable(),
                paymentMethodTypesService.methodTypes,
                featureFetcher.fetchBool(for: .simpleBuyFundsEnabled).asObservable()
            )
            .map { (beneficiaries: [BeneficiaryResponse], methodTypes: [PaymentMethodType], isEnabled: Bool) in
                guard isEnabled else { return [] }
                var limitsByBaseFiat: [FiatCurrency : FiatValue] = [:]
                let topLimits = methodTypes.accounts.map { $0.topLimit }
                for limit in topLimits {
                    limitsByBaseFiat[limit.currencyType] = limit
                }
                let activeLinkedBank = methodTypes.linkedBanks.filter(\.isActive)

                let linkedBanksResult: [Beneficiary] = activeLinkedBank.map {
                    Beneficiary(linkedBankData: $0)
                }

                let result: [Beneficiary] = beneficiaries.compactMap {
                    guard let currency = FiatCurrency(code: $0.currency) else { return nil }
                    return Beneficiary(response: $0, limit: limitsByBaseFiat[currency])
                }
                return result + linkedBanksResult
            }
            .catchErrorJustReturn([])
    }
}
