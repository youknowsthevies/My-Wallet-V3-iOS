// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol SessionTokenServiceAPI: class {
    func setupSessionToken() -> Completable
}
