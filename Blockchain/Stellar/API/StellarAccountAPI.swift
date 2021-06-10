// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift
import StellarKit
import stellarsdk

protocol StellarAccountAPI: SingleAccountBalanceFetching {
    var fetchStellarAccount: Single<StellarAccountDetails> { get }
}
