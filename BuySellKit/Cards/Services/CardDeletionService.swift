//
//  CardDeletionService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

public protocol PaymentMethodDeletionServiceAPI: AnyObject {
    /// Deletes a payment-method with a given identifier
    func delete(by id: String) -> Completable
}

final class CardDeletionService: PaymentMethodDeletionServiceAPI {
    
    // MARK: - Private Properties
    
    private let client: CardDeletionClientAPI
    private let cardListService: CardListServiceAPI
    
    // MARK: - Setup
    
    init(client: CardDeletionClientAPI,
         cardListService: CardListServiceAPI) {
        self.cardListService = cardListService
        self.client = client
    }
    
    func delete(by id: String) -> Completable {
        client
            .deleteCard(by: id)
            .andThen(cardListService.fetchCards())
            .asCompletable()
    }
}
