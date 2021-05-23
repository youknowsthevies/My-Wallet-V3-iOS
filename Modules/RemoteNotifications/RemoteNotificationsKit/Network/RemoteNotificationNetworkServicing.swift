// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

public protocol RemoteNotificationNetworkServicing: class {
    func register(with deviceToken: String,
                  using credentialsProvider: SharedKeyRepositoryAPI & GuidRepositoryAPI) -> Single<Void>
}
