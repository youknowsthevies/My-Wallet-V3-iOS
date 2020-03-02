//
//  SimpleBuyOrderDetailsResponse.swift
//  PlatformKit
//
//  Created by Paulo on 03/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SimpleBuyOrderDetailsResponse: Decodable {

    let id: String // "006bd84e-de7b-4697-8989-92eab7721bdd"
    
    let inputQuantity: String // Sell (fiat value minor for crypto)
    let inputCurrency: String // Sell (fiat value minor for crypto)
    
    let outputCurrency: String // Buy (the crypto we would like to buy)
    let state: String
}

