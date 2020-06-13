//
//  ServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

public final class ServiceProvider: ServiceProviderAPI {

    // MARK: - Properties

    public let eligibility: SimpleBuyEligibilityServiceAPI
    public let orderCancellation: SimpleBuyOrderCancellationServiceAPI
    public var orderCompletion: SimpleBuyPendingOrderCompletionServiceAPI {
        PendingOrderCompletionService(ordersService: ordersDetails)
    }
    public let orderConfirmation: SimpleBuyOrderConfirmationServiceAPI
    public let ordersDetails: SimpleBuyOrdersServiceAPI
    public let paymentMethodTypes: SimpleBuyPaymentMethodTypesServiceAPI
    public let pendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI
    public let suggestedAmounts: SimpleBuySuggestedAmountsServiceAPI
    public let supportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI
    public let supportedPairs: SimpleBuySupportedPairsServiceAPI
    public let supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI
    public let paymentMethods: SimpleBuyPaymentMethodsServiceAPI

    public let cache: EventCache

    private let orderCreation: SimpleBuyOrderCreationServiceAPI
    private let orderQuote: SimpleBuyOrderQuoteServiceAPI
    private let paymentAccount: SimpleBuyPaymentAccountServiceAPI
    
    public let settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI
    public let dataRepository: DataRepositoryAPI

    // MARK: - Setup
    
    public convenience init(cardServiceProvider: CardServiceProviderAPI,
                            recordingProvider: RecordingProviderAPI,
                            wallet: ReactiveWalletAPI,
                            authenticationService: NabuAuthenticationServiceAPI,
                            cacheSuite: CacheSuite,
                            settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI,
                            dataRepository: DataRepositoryAPI,
                            tiersService: KYCTiersServiceAPI,
                            featureFetcher: FeatureFetching) {
        self.init(cardServiceProvider: cardServiceProvider,
                  recordingProvider: recordingProvider,
                  wallet: wallet,
                  authenticationService: authenticationService,
                  simpleBuyClient: APIClient(),
                  cacheSuite: cacheSuite,
                  settings: settings,
                  dataRepository: dataRepository,
                  tiersService: tiersService,
                  featureFetcher: featureFetcher)
    }
    
    init(cardServiceProvider: CardServiceProviderAPI,
         recordingProvider: RecordingProviderAPI,
         wallet: ReactiveWalletAPI,
         authenticationService: NabuAuthenticationServiceAPI,
         simpleBuyClient: SimpleBuyClientAPI,
         cacheSuite: CacheSuite,
         settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI,
         dataRepository: DataRepositoryAPI,
         tiersService: KYCTiersServiceAPI,
         featureFetcher: FeatureFetching) {
        
        cache = EventCache(cacheSuite: cacheSuite)
        
        supportedPairs = SupportedPairsService(client: simpleBuyClient)
        
        supportedPairsInteractor = SupportedPairsInteractorService(
            featureFetcher: featureFetcher,
            pairsService: supportedPairs,
            fiatCurrencySettingsService: settings
        )
        suggestedAmounts = SuggestedAmountsService(
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService,
            fiatCurrencySettingsService: settings
        )
        ordersDetails = OrdersService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService
        )
        eligibility = EligibilityService(
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService,
            fiatCurrencyService: settings,
            featureFetcher: featureFetcher
        )
        orderQuote = OrderQuoteService(
            client: simpleBuyClient,
            authenticationService: authenticationService
        )
        paymentAccount = PaymentAccountService(
            client: simpleBuyClient,
            dataRepository: dataRepository,
            authenticationService: authenticationService,
            fiatCurrencyService: settings,
            patcher: PaymentAccountPatcher()
        )
        orderConfirmation = OrderConfirmationService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient,
            authenticationService: authenticationService
        )
        orderCancellation = OrderCancellationService(
            client: simpleBuyClient,
            orderDetailsService: ordersDetails,
            authenticationService: authenticationService
        )
        pendingOrderDetails = PendingOrderDetailsService(
            paymentAccountService: paymentAccount,
            ordersService: ordersDetails,
            cancallationService: orderCancellation
        )
        orderCreation = OrderCreationService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient,
            pendingOrderDetailsService: pendingOrderDetails,
            authenticationService: authenticationService
        )
        paymentMethods = PaymentMethodsService(
            client: simpleBuyClient,
            tiersService: tiersService,
            reactiveWallet: wallet,
            featureFetcher: featureFetcher,
            authenticationService: authenticationService,
            fiatCurrencyService: settings
        )
        paymentMethodTypes = SimpleBuyPaymentMethodTypesService(
            paymentMethodsService: paymentMethods,
            cardListService: cardServiceProvider.cardList
        )
        supportedCurrencies = SupportedCurrenciesService(
            featureFetcher: featureFetcher,
            pairsService: supportedPairs,
            fiatCurrencySettingsService: settings
        )

        self.dataRepository = dataRepository
        self.settings = settings
    }
    
    public func orderCreation(for paymentMethod: PaymentMethod.MethodType) -> SimpleBuyPendingOrderCreationServiceAPI {
        switch paymentMethod {
        case .bankTransfer:
            return BankOrderCreationService(
                paymentAccountService: paymentAccount,
                orderQuoteService: orderQuote,
                orderCreationService: orderCreation
            )
        case .card:
            return CardOrderCreationService(
                orderQuoteService: orderQuote,
                orderCreationService: orderCreation
            )
        }
    }
}
