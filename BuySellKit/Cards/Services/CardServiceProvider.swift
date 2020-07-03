//
//  CardServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import ToolKit

public final class CardServiceProvider: CardServiceProviderAPI {
    
    // MARK: - Card Specialized Services
    
    public let cardList: CardListServiceAPI
    public let cardUpdate: CardUpdateServiceAPI
    public let cardDeletion: CardDeletionServiceAPI
    public var cardActivation: CardActivationServiceAPI {
        CardActivationService(
            client: cardClient
        )
    }
    
    public let dataRepository: DataRepositoryAPI
    private let cardClient: CardClientAPI
    private let everyPayClient: EveryPayClientAPI
    
    // MARK: - Setup
    
    // MARK: - Setup
    
    public init(cardClient: CardClientAPI,
                everyPayClient: EveryPayClientAPI,
                wallet: ReactiveWalletAPI,
                dataRepository: DataRepositoryAPI,
                featureFetcher: FeatureFetching,
                analyticsRecorder: AnalyticsEventRecording,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        self.cardClient = cardClient
        self.everyPayClient = everyPayClient
        self.dataRepository = dataRepository
        
        cardList = CardListService(
            client: cardClient,
            reactiveWallet: wallet,
            featureFetcher: featureFetcher,
            fiatCurrencyService: fiatCurrencyService
        )
        cardDeletion = CardDeletionService(
            client: cardClient
        )
        cardUpdate = CardUpdateService(
            dataRepository: dataRepository,
            cardClient: cardClient,
            everyPayClient: everyPayClient,
            fiatCurrencyService: fiatCurrencyService,
            analyticsRecorder: analyticsRecorder
        )
    }
}
    
