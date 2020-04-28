//
//  PaymentMethodTypesService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit

/// The type of payment method
public enum SimpleBuyPaymentMethodType: Equatable {

    /// A card payment method (from the user's buy data)
    case card(CardData)
    
    /// Suggested payment methods (e.g bank-wire / card)
    case suggested(SimpleBuyPaymentMethod)
    
    var methodId: String? {
        switch self {
        case .card(let card):
            return card.identifier
        case .suggested:
            return nil
        }
    }
    
    var method: SimpleBuyPaymentMethod.MethodType {
        switch self {
        case .card:
            return .card
        case .suggested(let method):
            return method.type
        }
    }
}

/// A service that aggregates all the payment method types and possible methods.
public final class SimpleBuyPaymentMethodTypesService {

    // MARK: - Exposed
    
    public var methodTypes: Observable<[SimpleBuyPaymentMethodType]> {
        cachedValue.valueObservable
    }
    
    /// Preferred payment method
    public let preferredPaymentMethodTypeRelay = BehaviorRelay<SimpleBuyPaymentMethodType?>(value: nil)
    public var preferredPaymentMethodType: Observable<SimpleBuyPaymentMethodType?> {
        preferredPaymentMethodTypeRelay
            .flatMap(weak: self) { (self, preferredMethod) in
                if let preferredMethod = preferredMethod {
                    return .just(preferredMethod)
                } else {
                    return self.methodTypes.take(1)
                        .map { (types: [SimpleBuyPaymentMethodType]) -> [SimpleBuyPaymentMethodType] in
                            types.filter { type in
                                switch type {
                                case .card(let card):
                                    return card.state.isActive
                                case .suggested:
                                    return true
                                }
                            }
                        }
                        .map { $0.first }
                        .asObservable()
                        .catchErrorJustReturn(.none)
                }
            }
    }
    
    // MARK: - Injected
    
    private let paymentMethodsService: SimpleBuyPaymentMethodsServiceAPI
    private let cardListService: CardListServiceAPI
    
    // MARK: - Accessories
    
    private let cachedValue: CachedValue<[SimpleBuyPaymentMethodType]>
    
    // MARK: - Setup
    
    public init(paymentMethodsService: SimpleBuyPaymentMethodsServiceAPI,
                cardListService: CardListServiceAPI) {
        self.paymentMethodsService = paymentMethodsService
        self.cardListService = cardListService
                    
        cachedValue = .init(
            configuration: .init(
                identifier: "simple-buy-payment-method-types",
                refreshType: .onSubscription,
                fetchPriority: .fetchAll,
                flushNotificationName: .logout,
                fetchNotificationName: .login
            )
        )
        
        cachedValue.setFetch { () -> Observable<[SimpleBuyPaymentMethodType]> in
            Observable
                .combineLatest(
                    paymentMethodsService.paymentMethods,
                    cardListService.cards
                )
                .map { (methods, cards) in
                    let topLimit = (methods.first { $0.type == .card })?.max
                    let cardTypes = cards
                        .filter { $0.state.isUsable }
                        .map { card in
                            var card = card
                            if let limit = topLimit {
                                card.topLimit = limit
                            }
                            return card
                        }
                        .map { SimpleBuyPaymentMethodType.card($0) }
                    let suggestedMethods = methods.map { SimpleBuyPaymentMethodType.suggested($0) }
                    return cardTypes + suggestedMethods
                }
        }
    }
    
    public func fetchCards(andPrefer cardId: String) -> Completable {
        cardListService.fetchCards()
            .do(onSuccess: { [weak preferredPaymentMethodTypeRelay] cards in
                guard let data = cards.first(where: { $0.identifier == cardId }) else { return }
                preferredPaymentMethodTypeRelay?.accept(.card(data))
            })
            .asCompletable()
    }
}
