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
    case suggested(PaymentMethod)
    
    var methodId: String? {
        switch self {
        case .card(let card):
            return card.identifier
        case .suggested:
            return nil
        }
    }
    
    var method: PaymentMethod.MethodType {
        switch self {
        case .card(let data):
            return .card([data.type])
        case .suggested(let method):
            return method.type
        }
    }
}

public protocol SimpleBuyPaymentMethodTypesServiceAPI {
    
    var methodTypes: Observable<[SimpleBuyPaymentMethodType]> { get }
    
    var cards: Observable<[CardData]> { get }
    
    var preferredPaymentMethodTypeRelay: BehaviorRelay<SimpleBuyPaymentMethodType?> { get }
    
    var preferredPaymentMethodType: Observable<SimpleBuyPaymentMethodType?> { get }
    
    func fetchCards(andPrefer cardId: String) -> Completable
}

/// A service that aggregates all the payment method types and possible methods.
final class SimpleBuyPaymentMethodTypesService: SimpleBuyPaymentMethodTypesServiceAPI {

    // MARK: - Exposed
    
    public var methodTypes: Observable<[SimpleBuyPaymentMethodType]> {
        Observable
            .combineLatest(
                paymentMethodsService.fetch(),
                cardListService.cards
            )
            .map(weak: self) { (self, payload) in
                self.merge(paymentMethods: payload.0, with: payload.1)
            }
            .do(onNext: { [weak preferredPaymentMethodTypeRelay] types in
                if let preferredCard = types.cards.first {
                    preferredPaymentMethodTypeRelay?.accept(.card(preferredCard))
                } else if let preferredMethod = types.first {
                    preferredPaymentMethodTypeRelay?.accept(preferredMethod)
                }
            })
    }
    
    public var cards: Observable<[CardData]> {
        methodTypes.map { $0.cards }
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
    
    // MARK: - Setup
    
    init(paymentMethodsService: SimpleBuyPaymentMethodsServiceAPI,
         cardListService: CardListServiceAPI) {
        self.paymentMethodsService = paymentMethodsService
        self.cardListService = cardListService
    }
    
    public func fetchCards(andPrefer cardId: String) -> Completable {
        Single
            .zip(
                paymentMethodsService.paymentMethodsSingle,
                cardListService.fetchCards()
            )
            .map(weak: self) { (self, payload) in
                self.merge(paymentMethods: payload.0, with: payload.1)
            }
            .do(onSuccess: { [weak preferredPaymentMethodTypeRelay] types in
                let card = types
                    .compactMap { type -> CardData? in
                        switch type {
                        case .card(let cardData):
                            return cardData
                        case .suggested:
                            return nil
                        }
                    }
                    .first
                guard let data = card else { return }
                preferredPaymentMethodTypeRelay?.accept(.card(data))
            })
            .asCompletable()
    }
    
    private func merge(paymentMethods: [PaymentMethod],
                       with cards: [CardData]) -> [SimpleBuyPaymentMethodType] {
        let topLimit = (paymentMethods.first { $0.type.isCard })?.max
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
        let suggestedMethods = paymentMethods.map { SimpleBuyPaymentMethodType.suggested($0) }
        return cardTypes + suggestedMethods
    }
}

private extension Array where Element == SimpleBuyPaymentMethodType {
    var cards: [CardData] {
        compactMap { paymentMethod in
            switch paymentMethod {
            case .card(let data):
                return data
            case .suggested:
                return nil
            }
        }
    }
}
