// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift

protocol ExchangeAddressFetching {

    /// Fetches the Exchange address for a given asset type
    func fetchAddress(for asset: CryptoCurrency) -> Single<String>
}
