//
//  CardListServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CardListServiceAPI: class {
    
    /// Streams an updated array of cards.
    /// Expected to reactively stream the updated cards after
    var cards: Observable<[CardData]> { get }
    
    func card(by identifier: String) -> Single<CardData?>
        
    func fetchCards() -> Single<[CardData]>
    
    func doesCardExist(number: String, expiryMonth: String, expiryYear: String) -> Single<Bool>
}

