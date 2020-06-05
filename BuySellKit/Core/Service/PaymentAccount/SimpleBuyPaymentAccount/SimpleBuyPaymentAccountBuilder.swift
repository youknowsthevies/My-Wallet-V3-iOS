//
//  SimpleBuyPaymentAccountBuilder.swift
//  PlatformKit
//
//  Created by Paulo on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Builds the correct `SimpleBuyPaymentAccount` for a given `SimpleBuyPaymentAccountResponse`.
enum SimpleBuyPaymentAccountBuilder {

    // MARK: - Private Properties

    /// An array of possible `SimpleBuyPaymentAccount.Type`s
    private static let builders: [SimpleBuyPaymentAccount.Type] = [
        SimpleBuyPaymentAccountGBP.self,
        SimpleBuyPaymentAccountEUR.self,
        // TODO: Uncomment and handle when USD is supported
//        SimpleBuyPaymentAccountUSD.self
    ]

    // MARK: - Methods

    /// Builds, if possible, a valid `Payment Account` for the given `Payment Account Response`
    /// - Parameter response: A `SimpleBuyPaymentAccountResponse` object.
    /// - Returns: A `SimpleBuyPaymentAccount` object if there was a `SimpleBuyPaymentAccount.Type`  that succesfully built a valid object
    /// or `nil` if no builder succeeded.
    static func build(response: SimpleBuyPaymentAccountResponse) -> SimpleBuyPaymentAccount? {
        for builder in builders {
            if let result = builder.init(response: response) {
                return result
            }
        }
        return nil
    }
}
