//
//  PendingConfirmationCheckoutData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct PendingConfirmationCheckoutData {
    public let quote: SimpleBuyQuote
    public let checkoutData: CheckoutData
    
    func data(byAppending checkoutData: CheckoutData) -> PendingConfirmationCheckoutData {
        .init(quote: quote, checkoutData: checkoutData)
    }
    
    init(quote: SimpleBuyQuote, checkoutData: CheckoutData) {
        self.quote = quote
        self.checkoutData = checkoutData
    }
}
