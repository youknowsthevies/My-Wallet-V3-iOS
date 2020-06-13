//
//  PaymentAccount.swift
//  PlatformKit
//
//  Created by Paulo on 03/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit

/// Protocol describing a PaymentAccount
public protocol PaymentAccount {

    /// - Returns: A `Payment Account` if the response matches the requiriments, `nil` otherwise.
    init?(response: PaymentAccountResponse)
    
    /// A identifier for this SimpleBuyPaymentAccount.
    var identifier: String { get }
    
    /// The state in which this SimpleBuyPaymentAccount is.
    var state: SimpleBuyPaymentAccountProperty.State { get }
    
    /// The currency for this SimpleBuyPaymentAccount.
    var currency: FiatCurrency { get }
    
    /// An array of fields that fully represent this Payment Account for a human consumer.
    var fields: [SimpleBuyPaymentAccountProperty.Field] { get }
}
