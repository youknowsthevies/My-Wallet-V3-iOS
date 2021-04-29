// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol RemoteNotificationNetworkServicing: class {
    func register(with deviceToken: String,
                  using credentialsProvider: SharedKeyRepositoryAPI & GuidRepositoryAPI) -> Single<Void>
}
