//
//  SimpleBuyServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

final class SimpleBuyServiceProvider: SimpleBuyServiceProviderAPI {
    
    static let `default`: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider()
    
    // MARK: - Properties

    let supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI
    let supportedPairs: SimpleBuySupportedPairsServiceAPI
    let suggestedAmounts: SimpleBuySuggestedAmountsServiceAPI
    let ordersDetails: SimpleBuyOrdersServiceAPI
    let pendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI
    let availability: SimpleBuyAvailabilityServiceAPI
    let flowAvailability: SimpleBuyFlowAvailabilityServiceAPI
    let eligibility: SimpleBuyEligibilityServiceAPI
    let orderCreation: SimpleBuyOrderCreationServiceAPI
    let orderCancellation: SimpleBuyOrderCancellationServiceAPI
    let orderQuote: SimpleBuyOrderQuoteServiceAPI
    let paymentAccount: SimpleBuyPaymentAccountServiceAPI
    let cache: SimpleBuyEventCache
    
    let settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI
    let dataRepository: DataRepositoryAPI

    // MARK: - Setup
    
    init(walletManager: WalletManager = WalletManager.shared,
         wallet: ReactiveWalletAPI = ReactiveWallet(),
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         client: SimpleBuyClientAPI = SimpleBuyClient(),
         cacheSuite: CacheSuite = UserDefaults.standard,
         settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI = UserInformationServiceProvider.default.settings,
         dataRepository: DataRepositoryAPI = BlockchainDataRepository.shared,
         featureFetcher: FeatureFetching = AppFeatureConfigurator.shared) {
        
        cache = SimpleBuyEventCache(cacheSuite: cacheSuite)
        
        supportedPairs = SimpleBuySupportedPairsService(client: client)
        
        supportedPairsInteractor = SimpleBuySupportedPairsInteractorService(
            pairsService: supportedPairs,
            fiatCurrencySettingsService: settings
        )
        suggestedAmounts = SimpleBuySuggestedAmountsService(
            client: client,
            reactiveWallet: wallet,
            authenticationService: authenticationService,
            fiatCurrencySettingsService: settings
        )
        ordersDetails = SimpleBuyOrdersService(
            client: client,
            reactiveWallet: wallet,
            authenticationService: authenticationService
        )
        availability = SimpleBuyAvailabilityService(
            pairsService: supportedPairsInteractor,
            featureFetcher: featureFetcher
        )
        eligibility = SimpleBuyEligibilityService(
            client: client,
            reactiveWallet: wallet,
            authenticationService: authenticationService,
            fiatCurrencyService: settings,
            featureFetcher: featureFetcher
        )
        orderCreation = SimpleBuyOrderCreationService(
            client: client,
            ordersService: ordersDetails,
            authenticationService: authenticationService
        )
        orderQuote = SimpleBuyOrderQuoteService(
            client: client,
            authenticationService: authenticationService
        )
        paymentAccount = SimpleBuyPaymentAccountService(
            client: client,
            dataRepository: dataRepository,
            authenticationService: authenticationService,
            fiatCurrencyService: settings
        )
        pendingOrderDetails = SimpleBuyPendingOrderDetailsService(
            ordersService: ordersDetails,
            paymentAccountService: paymentAccount
        )
        orderCancellation = SimpleBuyOrderCancellationService(
            client: client,
            orderDetailsService: ordersDetails,
            authenticationService: authenticationService
        )
        flowAvailability = SimpleBuyFlowAvailabilityService(
            coinifyAccountRepository: CoinifyAccountRepository(bridge: walletManager.wallet),
            fiatCurrencyService: settings,
            reactiveWallet: wallet,
            supportedPairsService: supportedPairs
        )

        self.dataRepository = dataRepository
        self.settings = settings
    }
}
