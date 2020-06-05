//
//  SimpleBuyPendingConfirmationCheckoutData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct SimpleBuyPendingConfirmationCheckoutData {
    public let quote: SimpleBuyQuote
    public let checkoutData: SimpleBuyCheckoutData
    
    func data(byAppending checkoutData: SimpleBuyCheckoutData) -> SimpleBuyPendingConfirmationCheckoutData {
        return .init(quote: quote, checkoutData: checkoutData)
    }
    
    public init(quote: SimpleBuyQuote, checkoutData: SimpleBuyCheckoutData) {
        self.quote = quote
        self.checkoutData = checkoutData
    }
}
