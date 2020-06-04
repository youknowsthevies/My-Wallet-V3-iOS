//
//  CheckoutScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

final class CheckoutScreenInteractor {
    
    // MARK: - Types
    
    enum InteractionError: Error {
        case missingOrder
        case missingInternalOrderData
        case impossibleState
    }
    
    // MARK: - Properties
    
    private(set) var checkoutData: SimpleBuyCheckoutData
        
    // MARK: - Services
    
    private let orderCheckoutInterator: SimpleBuyOrderCheckoutInteractor
    private let cancellationService: SimpleBuyOrderCancellationServiceAPI
    private let confirmationService: SimpleBuyOrderConfirmationServiceAPI
    private let cardListService: CardListServiceAPI
    
    // MARK: - Setup
    
    init(cardListService: CardListServiceAPI,
         confirmationService: SimpleBuyOrderConfirmationServiceAPI,
         cancellationService: SimpleBuyOrderCancellationServiceAPI,
         orderCheckoutInterator: SimpleBuyOrderCheckoutInteractor,
         checkoutData: SimpleBuyCheckoutData) {
        self.orderCheckoutInterator = orderCheckoutInterator
        self.cardListService = cardListService
        self.confirmationService = confirmationService
        self.cancellationService = cancellationService
        self.checkoutData = checkoutData
    }
    
    /// Performs a setup of the data
    func setup() -> Single<SimpleBuyCheckoutInteractionData> {
        
        /// Must have an order to reach checkout screen as the order is created
        /// on the main screen (see: `BuyCryptoScreenInteractor`).
        guard let order = checkoutData.detailType.order else {
            return .error(InteractionError.missingOrder)
        }
        
        if order.is3DSConfirmedCardOrder || order.isPending3DSCardOrder {
            return orderCheckoutInterator.prepare(using: order)
        } else {
            return orderCheckoutInterator.prepare(using: self.checkoutData)
                .flatMap(weak: self) { (self, payload) in
                    self.set(data: payload.checkoutData)
                        .map { _ in
                            payload.interactionData
                        }
                }
        }
    }

    /// Confirms the order if needed and then continue
    /// - returns: Observable<(SimpleBuyCheckoutData, Bool)> that emits pairs composed of a  SimpleBuyCheckoutData
    ///  and a `Bool` flag informing if the order needed confirmation.
    func `continue`() -> Observable<(SimpleBuyCheckoutData, Bool)> {
        guard let order = checkoutData.detailType.order else {
            return .error(InteractionError.missingOrder)
        }
        
        if order.isPendingConfirmation {
            return confirmationService
                .confirm(checkoutData: checkoutData)
                .flatMap(weak: self) { (self, data) -> Single<SimpleBuyCheckoutData> in
                    self.set(data: data)
                }
                .map { ($0, true) }
                .asObservable()
        } else {
            return .just((checkoutData, false))
        }
    }
    
    /// Cancels the order if possible
    func cancelIfPossible() -> Single<Bool> {
        guard let order = checkoutData.detailType.order else {
            return .error(InteractionError.missingOrder)
        }
        if order.isPendingConfirmation {
            return cancellationService
                .cancel(order: order.identifier)
                .andThen(.just(true))
        } else {
            return .just(false)
        }
    }
    
    private func set(data: SimpleBuyCheckoutData) -> Single<SimpleBuyCheckoutData> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.checkoutData = data
                observer(.success(data))
                return Disposables.create()
            }
    }
}
