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

public protocol CardDeletionServiceAPI: class {
    /// Deletes a card with a given identifier
    func deleteCard(by id: String) -> Completable
}

public final class CardDeletionService: CardDeletionServiceAPI {
    
    // MARK: - Private Properties
    
    private let client: CardDeletionClientAPI
    
    // MARK: - Setup
    
    public init(client: CardDeletionClientAPI) {
        self.client = client
    }
    
    public func deleteCard(by id: String) -> Completable {
        self.client.deleteCard(by: id)
    }
    
}
