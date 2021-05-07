// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import StellarKit

protocol StellarDependenciesAPI {
    var accounts: StellarAccountAPI { get }
}
