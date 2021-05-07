// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift
import StellarKit
import stellarsdk

protocol StellarAccountAPI: CryptoAccountBalanceFetching {
    func currentStellarAccount(fromCache: Bool) -> Single<StellarAccount>
    func clear()
}
