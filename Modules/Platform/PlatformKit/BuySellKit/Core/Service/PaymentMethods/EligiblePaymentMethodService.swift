// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift
import ToolKit

final class EligiblePaymentMethodsService: PaymentMethodsServiceAPI {
    // MARK: - Public properties

    let paymentMethods: Observable<[PaymentMethod]>

    let paymentMethodsSingle: Single<[PaymentMethod]>

    let supportedCardTypes: Single<Set<CardType>>

    // MARK: - Private properties

    private let paymentMethodsRelay = BehaviorRelay<[PaymentMethod]?>(value: nil)

    private let eligibleMethodsClient: PaymentEligibleMethodsClientAPI
    private let tiersService: KYCTiersServiceAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    // MARK: - Setup

    init(eligibleMethodsClient: PaymentEligibleMethodsClientAPI = resolve(),
         tiersService: KYCTiersServiceAPI = resolve(),
         reactiveWallet: ReactiveWalletAPI = resolve(),
         enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve()) {
        self.eligibleMethodsClient = eligibleMethodsClient
        self.tiersService = tiersService
        self.fiatCurrencyService = fiatCurrencyService
        self.enabledCurrenciesService = enabledCurrenciesService
        NotificationCenter.when(.logout) { [weak paymentMethodsRelay] _ in
            paymentMethodsRelay?.accept(nil)
        }

        let enabledFiatCurrencies = enabledCurrenciesService.allEnabledFiatCurrencies
        let bankTransferEligibleFiatCurrencies = enabledCurrenciesService.bankTransferEligibleFiatCurrencies
        let fetch = fiatCurrencyService.fiatCurrencyObservable
            .flatMap { [tiersService, eligibleMethodsClient] (fiatCurrency) ->  Observable<[PaymentMethod]> in
                tiersService.fetchTiers()
                    .map(\.isTier2Approved)
                    .flatMap { isTier2Approved -> Single<[PaymentMethodsResponse.Method]> in
                        eligibleMethodsClient.eligiblePaymentMethods(for: fiatCurrency.code,
                                                                     eligibleOnly: isTier2Approved)
                    }
                    .map { methods in
                        Array<PaymentMethod>.init(
                            methods: methods,
                            currency: fiatCurrency,
                            supportedFiatCurrencies: enabledFiatCurrencies
                        )
                    }
                    .map { paymentMethods in
                        paymentMethods.filter { paymentMethod in
                            switch paymentMethod.type {
                            case .card:
                                return true
                            case .funds(let currencyType):
                                return currencyType.code == fiatCurrency.code
                            case .bankTransfer:
                                // this gets special treatment as we currently only support bank linkage in the US.
                                return bankTransferEligibleFiatCurrencies.contains(paymentMethod.min.currencyType)
                            case .bankAccount:
                                // Filter out bank transfer details from currencies we do not
                                //  have local support/UI.
                                return enabledFiatCurrencies.contains(paymentMethod.min.currencyType)
                            }
                        }
                    }
                    .asObservable()
            }
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)

        paymentMethods = fetch

        paymentMethodsSingle = fetch
            .take(1)
            .asSingle()

        supportedCardTypes = fetch
            .take(1)
            .asSingle()
            .map { paymentMethods in
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
}
