// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol AssetAccountRepositoryAPI: AnyObject {
    var accounts: Single<[AssetAccount]> { get }
}
