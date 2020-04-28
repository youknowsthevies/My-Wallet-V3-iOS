//
//  CardDeletionServiceAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CardDeletionServiceAPI: class {
    /// Deletes a card with a given identifier
    func deleteCard(by id: String) -> Completable
}
