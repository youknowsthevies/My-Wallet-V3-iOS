// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol ActivityItemEventDetailsFetcherAPI: AnyObject {
    associatedtype Model
    func details(for identifier: String) -> Observable<Model>
}
