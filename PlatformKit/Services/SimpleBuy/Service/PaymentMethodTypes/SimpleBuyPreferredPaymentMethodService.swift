//
//  SimpleBuyPreferredPaymentMethod.swift
//  PlatformKit
//
//  Created by Daniel Huri on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// TODO: Move logic here from `SimpleBuyPaymentMethodTypesService`
final class SimpleBuyPreferredPaymentMethodService {
    
    // MARK: - Injected
    
    private let paymentMethodTypesService: SimpleBuyPaymentMethodTypesService
    
    // MARK: - Setup
    
    init(paymentMethodTypesService: SimpleBuyPaymentMethodTypesService) {
        self.paymentMethodTypesService = paymentMethodTypesService
    }
}
