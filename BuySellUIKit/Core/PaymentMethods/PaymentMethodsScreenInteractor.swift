//
//  PaymentMethodsScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import BuySellKit

final class PaymentMethodsScreenInteractor {
    
    // MARK: - Properties
    
    /// Streams the available payment methods
    var methods: Single<[SimpleBuyPaymentMethodType]> {
        service.methodTypes
            .map { types in
                types
                    .filter { type in
                        switch type {
                        case .card(let data):
                            return data.state == .active
                        case .suggested:
                            return true
                        }
                    }
            }
            .take(1)
            .asSingle()
    }
    
    // MARK: - Injected
    
    private let service: SimpleBuyPaymentMethodTypesService
    
    // MARK: - Setup
    
    init(service: SimpleBuyPaymentMethodTypesService) {
        self.service = service
    }
    
    func select(method: SimpleBuyPaymentMethodType) {
        service.preferredPaymentMethodTypeRelay.accept(method)
    }
}
