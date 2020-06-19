//
//  PaymentAccountBuilder.swift
//  PlatformKit
//
//  Created by Paulo on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Builds the correct `PaymentAccount` for a given `PaymentAccountResponse`.
enum PaymentAccountBuilder {

    // MARK: - Private Properties

    /// An array of possible `PaymentAccount.Type`s
    private static let builders: [PaymentAccount.Type] = [
        PaymentAccountGBP.self,
        PaymentAccountEUR.self,
        // TODO: Uncomment and handle when USD is supported
//        PaymentAccountUSD.self
    ]

    // MARK: - Methods

    /// Builds, if possible, a valid `Payment Account` for the given `Payment Account Response`
    /// - Parameter response: A `PaymentAccountResponse` object.
    /// - Returns: A `PaymentAccount` object if there was a `PaymentAccount.Type`  that succesfully built a valid object
    /// or `nil` if no builder succeeded.
    static func build(response: PaymentAccountResponse) -> PaymentAccount? {
        for builder in builders {
            if let result = builder.init(response: response) {
                return result
            }
        }
        return nil
    }
}
