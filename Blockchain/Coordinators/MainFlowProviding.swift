// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol MainFlowProviding: AnyObject {
    func setupMainFlow() -> Single<UIViewController>
}
