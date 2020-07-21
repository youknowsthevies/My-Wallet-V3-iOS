//
//  PaymentMethodTypesService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit
import PlatformKit

/// The type of payment method
public enum PaymentMethodType: Equatable {

    /// A card payment method (from the user's buy data)
    case card(CardData)
    
    /// An account for an asset. Currency supports fiat
    case account(MoneyValueBalancePairs)
    
    /// Suggested payment methods (e.g bank-wire / card)
    case suggested(PaymentMethod)
    
    public var method: PaymentMethod.MethodType {
        switch self {
        case .card(let data):
            return .card([data.type])
        case .account(let balance):
            return .funds(balance.base.currencyType)
        case .suggested(let method):
            return method.type
        }
    }
    
    var methodId: String? {
        switch self {
        case .card(let card):
            return card.identifier
        case .suggested:
            return nil
        case .account:
            return nil
        }
    }
}

public protocol PaymentMethodTypesServiceAPI {
    
    var methodTypes: Observable<[PaymentMethodType]> { get }
    
    var cards: Observable<[CardData]> { get }
    
    var preferredPaymentMethodTypeRelay: BehaviorRelay<PaymentMethodType?> { get }
    
    var preferredPaymentMethodType: Observable<PaymentMethodType?> { get }
    
    func fetchCards(andPrefer cardId: String) -> Completable
}

/// A service that aggregates all the payment method types and possible methods.
final class PaymentMethodTypesService: PaymentMethodTypesServiceAPI {

    // MARK: - Exposed
    
    var methodTypes: Observable<[PaymentMethodType]> {
        Observable
            .combineLatest(
                paymentMethodsService.fetch(),
                cardListService.cards,
                balanceProvider.fiatFundsBalances
            )
            .map(weak: self) { (self, payload) in
                self.merge(paymentMethods: payload.0, cards: payload.1, balances: payload.2)
            }
    }
    
    var cards: Observable<[CardData]> {
        methodTypes.map { $0.cards }
    }
    
    /// Preferred payment method
    let preferredPaymentMethodTypeRelay = BehaviorRelay<PaymentMethodType?>(value: nil)
    var preferredPaymentMethodType: Observable<PaymentMethodType?> {
        preferredPaymentMethodTypeRelay
            .flatMap(weak: self) { (self, preferredMethod) in
                if let preferredMethod = preferredMethod {
                    return .just(preferredMethod)
                } else {
                    return self.methodTypes.take(1)
                        .map { (types: [PaymentMethodType]) -> [PaymentMethodType] in
                            types.filter { type in
                                switch type {
                                case .card(let card):
                                    return card.state.isActive
                                case .account:
                                    return true
                                case .suggested(let method):
                                    return !method.type.isBankTransfer
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
    
    private let paymentMethodsService: PaymentMethodsServiceAPI
    private let cardListService: CardListServiceAPI
    private let balanceProvider: BalanceProviding
    
    // MARK: - Setup
    
    init(paymentMethodsService: PaymentMethodsServiceAPI,
         cardListService: CardListServiceAPI,
         balanceProvider: BalanceProviding) {
        self.paymentMethodsService = paymentMethodsService
        self.cardListService = cardListService
        self.balanceProvider = balanceProvider
    }
    
    func fetchCards(andPrefer cardId: String) -> Completable {
        Single
            .zip(
                paymentMethodsService.paymentMethodsSingle,
                cardListService.fetchCards(),
                balanceProvider.fiatFundsBalances.take(1).asSingle()
            )
            .map(weak: self) { (self, payload) in
                self.merge(paymentMethods: payload.0, cards: payload.1, balances: payload.2)
            }
            .do(onSuccess: { [weak preferredPaymentMethodTypeRelay] types in
                let card = types
                    .compactMap { type -> CardData? in
                        switch type {
                        case .card(let cardData):
                            return cardData
                        case .suggested, .account:
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
                       cards: [CardData],
                       balances: MoneyBalancePairsCalculationStates) -> [PaymentMethodType] {
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
            .map { PaymentMethodType.card($0) }
        let suggestedMethods = paymentMethods.map { PaymentMethodType.suggested($0) }
        
        let fundsCurrencies = Set(
            paymentMethods
                .compactMap { method -> CurrencyType? in
                    switch method.type {
                    case .funds(let currencyType):
                        return currencyType
                    default:
                        return nil
                    }
                }
        )
        
        let balances = balances.all
            .compactMap { $0.value }
            .filter { fundsCurrencies.contains($0.baseCurrency) }
            .map { PaymentMethodType.account($0) }
        
        return balances + cardTypes + suggestedMethods
    }
}

private extension Array where Element == PaymentMethodType {
    var cards: [CardData] {
        compactMap { paymentMethod in
            switch paymentMethod {
            case .card(let data):
                return data
            case .suggested, .account:
                return nil
            }
        }
    }
    
    var accounts: [MoneyValueBalancePairs] {
        compactMap { paymentMethod in
            switch paymentMethod {
            case .account(let balance):
                return balance
            case .suggested, .card:
                return nil
            }
        }
        
    }
}
