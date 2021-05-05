// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardDeletionClientAPI: class {
    func deleteCard(by id: String) -> Completable
}
