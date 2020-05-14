//
//  CardServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

final class CardServiceProvider: CardServiceProviderAPI {
    
    static let `default`: CardServiceProviderAPI = CardServiceProvider()
        
    // MARK: - Card Specialized Services
    
    let cardList: CardListServiceAPI
    let cardUpdate: CardUpdateServiceAPI
    let cardDeletion: CardDeletionServiceAPI
    var cardActivation: CardActivationServiceAPI {
        CardActivationService(
            client: cardClient,
            authenticationService: authenticationService
        )
    }
    
    let dataRepository: DataRepositoryAPI
    private let cardClient: CardClientAPI
    private let everyPayClient: EveryPayClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    
    // MARK: - Setup
    
    // MARK: - Setup
    
    init(cardClient: CardClientAPI = CardClient(),
         everyPayClient: EveryPayClientAPI = EveryPayClient(),
         wallet: ReactiveWalletAPI = ReactiveWallet(),
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         dataRepository: DataRepositoryAPI = BlockchainDataRepository.shared,
         featureFetcher: FeatureFetching = AppFeatureConfigurator.shared,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings) {
        self.cardClient = cardClient
        self.everyPayClient = everyPayClient
        self.authenticationService = authenticationService
        self.dataRepository = dataRepository
        
        cardList = CardListService(
            client: cardClient,
            reactiveWallet: wallet,
            featureFetcher: featureFetcher,
            authenticationService: authenticationService,
            fiatCurrencyService: fiatCurrencyService
        )
        cardDeletion = CardDeletionService(
            client: cardClient,
            authenticationService: authenticationService
        )
        cardUpdate = CardUpdateService(
            dataRepository: dataRepository,
            cardClient: cardClient,
            everyPayClient: everyPayClient,
            fiatCurrencyService: fiatCurrencyService,
            analyticsRecorder: analyticsRecorder,
            authenticationService: authenticationService
        )
    }
}
    
