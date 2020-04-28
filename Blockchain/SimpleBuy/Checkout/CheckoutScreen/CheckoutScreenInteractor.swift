//
//  CheckoutScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class CheckoutScreenInteractor {
    
    // MARK: - Properties
    
    private(set) var checkoutData: SimpleBuyCheckoutData
    
    private var order: SimpleBuyOrderDetails {
        switch checkoutData.detailType {
        case .order(let details):
            return details
        case .candidate:
            fatalError("Order must be present when accessing it")
        }
    }
    
    // MARK: - Services
    
    private let creationService: SimpleBuyPendingOrderCreationServiceAPI
    private let cancellationService: SimpleBuyOrderCancellationServiceAPI
    private let confirmationService: SimpleBuyOrderConfirmationServiceAPI

    // MARK: - Setup
    
    init(creationService: SimpleBuyPendingOrderCreationServiceAPI,
         confirmationService: SimpleBuyOrderConfirmationServiceAPI,
         cancellationService: SimpleBuyOrderCancellationServiceAPI,
         checkoutData: SimpleBuyCheckoutData) {
        self.creationService = creationService
        self.confirmationService = confirmationService
        self.cancellationService = cancellationService
        self.checkoutData = checkoutData
    }
    
    func setup() -> Single<SimpleBuyQuote> {
        creationService
            .create(using: checkoutData)
            .flatMap(weak: self) { (self, data) in
                self.set(data: data.checkoutData)
                    .map { _ in data.quote }
            }
    }

    /// Confirms the order
    func confirm() -> Observable<SimpleBuyCheckoutData> {
        confirmationService
            .confirm(checkoutData: checkoutData)
            .flatMap(weak: self) { (self, data) -> Single<SimpleBuyCheckoutData> in
                self.set(data: data)
            }
            .asObservable()
    }
    
    func cancel() -> Completable {
        cancellationService.cancel(order: order.identifier)
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
