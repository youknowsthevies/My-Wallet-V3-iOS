//
//  SimpleBuyServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

public final class SimpleBuyServiceProvider: SimpleBuyServiceProviderAPI {

    // MARK: - Properties

    public let eligibility: SimpleBuyEligibilityServiceAPI
    public let orderCancellation: SimpleBuyOrderCancellationServiceAPI
    public var orderCompletion: SimpleBuyPendingOrderCompletionServiceAPI {
        SimpleBuyPendingOrderCompletionService(ordersService: ordersDetails)
    }
    public let orderConfirmation: SimpleBuyOrderConfirmationServiceAPI
    public let ordersDetails: SimpleBuyOrdersServiceAPI
    public let paymentMethodTypes: SimpleBuyPaymentMethodTypesService
    public let pendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI
    public let suggestedAmounts: SimpleBuySuggestedAmountsServiceAPI
    public let supportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI
    public let supportedPairs: SimpleBuySupportedPairsServiceAPI
    public let supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI
    public let paymentMethods: SimpleBuyPaymentMethodsServiceAPI

    public let cache: SimpleBuyEventCache

    private let orderCreation: SimpleBuyOrderCreationServiceAPI
    private let orderQuote: SimpleBuyOrderQuoteServiceAPI
    private let paymentAccount: SimpleBuyPaymentAccountServiceAPI
    
    public let settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI
    public let dataRepository: DataRepositoryAPI

    // MARK: - Setup
    
    public init(cardServiceProvider: CardServiceProviderAPI,
                recordingProvider: RecordingProviderAPI,
                wallet: ReactiveWalletAPI,
                authenticationService: NabuAuthenticationServiceAPI,
                simpleBuyClient: SimpleBuyClientAPI,
                cacheSuite: CacheSuite,
                settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI,
                dataRepository: DataRepositoryAPI,
                tiersService: KYCTiersServiceAPI,
                featureFetcher: FeatureFetching) {
        
        cache = SimpleBuyEventCache(cacheSuite: cacheSuite)
        
        supportedPairs = SimpleBuySupportedPairsService(client: simpleBuyClient)
        
        supportedPairsInteractor = SimpleBuySupportedPairsInteractorService(
            featureFetcher: featureFetcher,
            pairsService: supportedPairs,
            fiatCurrencySettingsService: settings
        )
        suggestedAmounts = SimpleBuySuggestedAmountsService(
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService,
            fiatCurrencySettingsService: settings
        )
        ordersDetails = SimpleBuyOrdersService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService
        )
        eligibility = SimpleBuyEligibilityService(
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService,
            fiatCurrencyService: settings,
            featureFetcher: featureFetcher
        )
        orderQuote = SimpleBuyOrderQuoteService(
            client: simpleBuyClient,
            authenticationService: authenticationService
        )
        paymentAccount = SimpleBuyPaymentAccountService(
            client: simpleBuyClient,
            dataRepository: dataRepository,
            authenticationService: authenticationService,
            fiatCurrencyService: settings
        )
        orderConfirmation = SimpleBuyOrderConfirmationService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient,
            authenticationService: authenticationService
        )
        orderCancellation = SimpleBuyOrderCancellationService(
            client: simpleBuyClient,
            orderDetailsService: ordersDetails,
            authenticationService: authenticationService
        )
        pendingOrderDetails = SimpleBuyPendingOrderDetailsService(
            paymentAccountService: paymentAccount,
            ordersService: ordersDetails,
            cancallationService: orderCancellation
        )
        orderCreation = SimpleBuyOrderCreationService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient,
            pendingOrderDetailsService: pendingOrderDetails,
            authenticationService: authenticationService
        )
        paymentMethods = SimpleBuyPaymentMethodsService(
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
        supportedCurrencies = SimpleBuySupportedCurrenciesService(
            featureFetcher: featureFetcher,
            pairsService: supportedPairs,
            fiatCurrencySettingsService: settings
        )

        self.dataRepository = dataRepository
        self.settings = settings
    }
    
    public func orderCreation(for paymentMethod: SimpleBuyPaymentMethod.MethodType) -> SimpleBuyPendingOrderCreationServiceAPI {
        switch paymentMethod {
        case .bankTransfer:
            return SimpleBuyBankOrderCreationService(
                paymentAccountService: paymentAccount,
                orderQuoteService: orderQuote,
                orderCreationService: orderCreation
            )
        case .card:
            return SimpleBuyCardOrderCreationService(
                orderQuoteService: orderQuote,
                orderCreationService: orderCreation
            )
        }
    }
}
