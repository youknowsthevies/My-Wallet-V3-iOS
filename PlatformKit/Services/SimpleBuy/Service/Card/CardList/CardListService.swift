//
//  CardUpdateService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class CardListService: CardListServiceAPI {
    
    // MARK: - Public properties
        
    public var cards: Observable<[CardData]> {
        cachedValue.valueObservable
    }
    
    // MARK: - Private properties
    
    private let cachedValue: CachedValue<[CardData]>
    
    // MARK: - Setup
    
    public init(client: CardListClientAPI,
                reactiveWallet: ReactiveWalletAPI,
                authenticationService: NabuAuthenticationServiceAPI,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        cachedValue = .init(
            configuration: .init(
                identifier: "card-list-service",
                refreshType: .onSubscription,
                fetchPriority: .fetchAll,
                flushNotificationName: .logout,
                fetchNotificationName: .login
            )
        )
        
        cachedValue
            .setFetch { () -> Observable<[CardData]> in
                reactiveWallet.waitUntilInitializedSingle
                    .asObservable()
                    .flatMap { authenticationService.tokenString }
                    .flatMap { token in
                        client.cardList(by: token)
                    }
                    .map { .init(response: $0) }
            }
    }
    
    public func card(by identifier: String) -> Single<CardData?> {
        cards
            .take(1)
            .asSingle()
            .map { $0.filter { $0.identifier == identifier }.first }
    }
    
    public func fetchCards() -> Single<[CardData]> {
        cachedValue.fetchValueObservable
            .take(1)
            .asSingle()
    }
}
