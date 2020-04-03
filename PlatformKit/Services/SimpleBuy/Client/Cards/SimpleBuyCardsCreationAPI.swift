//
//  SimpleBuyCardsCreationAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyCardsCreationAPI {
    func createCard(token: String, currencyCode: String) -> Single<SimpleBuyCreditCard>
    
    /// Allows updating of details of card (e.g. billing address).
    func update(token: String, address: SimpleBuyCreditCard.BillingAddress, beneficiaryID: String) -> Single<SimpleBuyCreditCard>
    
    func deleteCard(toke: String, beneficiaryID: String) -> Completable
}
