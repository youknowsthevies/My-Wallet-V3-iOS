//
//  CardUpdateService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

public protocol CardListServiceAPI: class {
    
    /// Streams an updated array of cards.
    /// Expected to reactively stream the updated cards after
    var cards: Observable<[CardData]> { get }
    
    func card(by identifier: String) -> Single<CardData?>
        
    func fetchCards() -> Single<[CardData]>
    
    func doesCardExist(number: String, expiryMonth: String, expiryYear: String) -> Single<Bool>
}

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
                featureFetcher: FeatureFetching,
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
                    .map { Array<CardData>.init(response: $0) }
                    .flatMap { cards -> Observable<[CardData]> in
                        featureFetcher.fetchBool(for: .simpleBuyCardsEnabled)
                            .map { $0 ? cards : [] }
                            .asObservable()
                    }
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
    
    public func doesCardExist(number: String, expiryMonth: String, expiryYear: String) -> Single<Bool> {
        cards.take(1)
            .asSingle()
            .map {
                $0.contains {
                    $0.number.suffix(4) == number.suffix(4) &&
                    $0.month == expiryMonth &&
                    $0.year.suffix(2) == expiryYear.suffix(2) &&
                    $0.state != .blocked
                }
            }
    }
}
