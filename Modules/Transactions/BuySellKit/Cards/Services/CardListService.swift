//
//  CardUpdateService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol CardListServiceAPI: class {
    
    /// Streams an updated array of cards.
    /// Expected to reactively stream the updated cards after
    var cards: Observable<[CardData]> { get }

    var cardsSingle: Single<[CardData]> { get }
    
    func card(by identifier: String) -> Single<CardData?>
        
    func fetchCards() -> Single<[CardData]>
    
    func doesCardExist(number: String, expiryMonth: String, expiryYear: String) -> Single<Bool>
}

public final class CardListService: CardListServiceAPI {
    
    // MARK: - Public properties
        
    public var cards: Observable<[CardData]> {
        cardsRelay
            .flatMap(weak: self) { (self, cardData) -> Observable<[CardData]> in
                guard let cardData = cardData else {
                    return self.fetchCards().asObservable()
                }
                return .just(cardData)
            }
            .share(replay: 1, scope: .whileConnected)
            .distinctUntilChanged()
    }

    public var cardsSingle: Single<[CardData]> {
        cards.take(1).asSingle()
    }
    
    // MARK: - Private properties

    private let cardsRelay = BehaviorRelay<[CardData]?>(value: nil)

    private let client: CardListClientAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let featureFetcher: FeatureFetching
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI

    // MARK: - Setup
    
    public init(client: CardListClientAPI = resolve(),
                reactiveWallet: ReactiveWalletAPI = resolve(),
                featureFetcher: FeatureFetching = resolve(),
                fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve()) {
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.featureFetcher = featureFetcher
        self.fiatCurrencyService = fiatCurrencyService

        NotificationCenter.when(.logout) { [weak self] _ in
            self?.cardsRelay.accept(nil)
        }
        NotificationCenter.when(.login) { [weak self] _ in
            self?.cardsRelay.accept(nil)
        }
    }
    
    public func card(by identifier: String) -> Single<CardData?> {
        cards
            .take(1)
            .asSingle()
            .map { $0.filter { $0.identifier == identifier }.first }
    }

    /// Always fetches data from API, updates relay on success.
    private func createFetchSingle() -> Single<[CardData]> {
        featureFetcher
            .fetchBool(for: .simpleBuyCardsEnabled)
            .flatMap(weak: self) { (self, enabled) -> Single<[CardPayload]> in
                guard enabled else {
                    return .just([])
                }
                return self.client.cardList
            }
            .map { Array<CardData>.init(response: $0) }
            .do(onSuccess: { [weak self] (cards: [CardData]) in
                self?.cardsRelay.accept(cards)
            })
            .catchErrorJustReturn([])
    }

    public func fetchCards() -> Single<[CardData]> {
        createFetchSingle()
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
