//
//  SimpleBuyCardsProvidingAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyCardsProvidingAPI {
    func fetchCardDetails(token: String, beneficiaryID: String) -> Single<SimpleBuyCreditCard>
    func fetchCards(token: String) -> Single<[SimpleBuyCreditCard]>
}
