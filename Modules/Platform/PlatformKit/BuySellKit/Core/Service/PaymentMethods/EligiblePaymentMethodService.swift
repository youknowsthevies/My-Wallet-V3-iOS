// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift
import ToolKit

final class EligiblePaymentMethodsService: PaymentMethodsServiceAPI {
    // MARK: - Public properties

    var paymentMethods: Observable<[PaymentMethod]> {
        paymentMethodsRelay
            .flatMap(weak: self) { (self, paymentMethods) -> Observable<[PaymentMethod]> in
                guard let paymentMethods = paymentMethods else {
                    return self.fetch()
                }
                return .just(paymentMethods)
            }
            .distinctUntilChanged()
            .share()
    }

    var paymentMethodsSingle: Single<[PaymentMethod]> {
        paymentMethodsRelay
            .take(1)
            .asSingle()
            .flatMap(weak: self) { (self, paymentMethods) -> Single<[PaymentMethod]> in
                guard let paymentMethods = paymentMethods else {
                    return self.fetch().take(1).asSingle()
                }
                return .just(paymentMethods)
            }
    }

    var supportedCardTypes: Single<Set<CardType>> {
        paymentMethodsSingle.map { paymentMethods in
            guard let card = paymentMethods.first(where: { $0.type.isCard }) else {
                return []
            }
            switch card.type {
            case .card(let types):
                return types
            case .bankAccount, .bankTransfer, .funds:
                return []
            }
        }
    }

    // MARK: - Private properties

    private let paymentMethodsRelay = BehaviorRelay<[PaymentMethod]?>(value: nil)

    private let eligibleMethodsClient: PaymentEligibleMethodsClientAPI
    private let tiersService: KYCTiersServiceAPI
    private let enabledFiatCurrencies: [FiatCurrency]
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI

    // MARK: - Setup

    init(eligibleMethodsClient: PaymentEligibleMethodsClientAPI = resolve(),
         tiersService: KYCTiersServiceAPI = resolve(),
         reactiveWallet: ReactiveWalletAPI = resolve(),
         enabledFiatCurrencies: [FiatCurrency] = { () -> EnabledCurrenciesServiceAPI in
            resolve()
         }().allEnabledFiatCurrencies,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve()) {
        self.eligibleMethodsClient = eligibleMethodsClient
        self.tiersService = tiersService
        self.fiatCurrencyService = fiatCurrencyService
        self.enabledFiatCurrencies = enabledFiatCurrencies

        NotificationCenter.when(.logout) { [weak paymentMethodsRelay] _ in
            paymentMethodsRelay?.accept(nil)
        }
    }

    func refresh() -> Completable {
        fetch().ignoreElements()
    }

    func fetch() -> Observable<[PaymentMethod]> {
        let enabledFiatCurrencies = self.enabledFiatCurrencies
        return fiatCurrencyService.fiatCurrencyObservable
            .flatMap(weak: self) { (self, fiatCurrency) -> Observable<[PaymentMethod]> in
                self.tiersService.fetchTiers()
                    .map { $0.isTier2Approved }
                    .flatMap { isTier2Approved -> Single<[PaymentMethodsResponse.Method]> in
                        self.eligibleMethodsClient.eligiblePaymentMethods(for: fiatCurrency.code,
                                                                          onlyEligible: isTier2Approved)
                    }
                    .map {
                        Array<PaymentMethod>.init(
                            methods: $0,
                            currency: fiatCurrency,
                            supportedFiatCurrencies: enabledFiatCurrencies
                        )
                    }
                    .map { paymentMethods in
                        paymentMethods.filter {
                            switch $0.type {
                            case .card:
                                return true
                            case .funds(let currencyType):
                                return currencyType.code == fiatCurrency.code
                            case .bankTransfer:
                                return enabledFiatCurrencies.contains($0.min.currencyType)
                            case .bankAccount:
                                // Filter out bank transfer details from currencies we do not
                                //  have local support/UI.
                                return enabledFiatCurrencies.contains($0.min.currencyType)
                            }
                        }
                    }
                    .asObservable()
            }
            .distinctUntilChanged()
            .do(onNext: { [weak self] paymentMethods in
                self?.paymentMethodsRelay.accept(paymentMethods)
            })
            .share()
    }
}
