// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol SessionTokenServiceAPI: AnyObject {
    func setupSessionToken() -> Completable
}
