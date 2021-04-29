// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol PayloadRepositoryAPI: class {
    func set(payload: String) -> Completable
}
