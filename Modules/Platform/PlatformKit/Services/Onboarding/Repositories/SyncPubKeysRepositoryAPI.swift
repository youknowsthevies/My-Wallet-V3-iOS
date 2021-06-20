// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol SyncPubKeysRepositoryAPI: AnyObject {
    func set(syncPubKeys: Bool) -> Completable
}
