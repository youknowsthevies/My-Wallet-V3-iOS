// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol PayloadRepositoryAPI: AnyObject {
    func set(payload: String) -> Completable
}
