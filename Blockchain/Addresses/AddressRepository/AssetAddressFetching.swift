// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift

protocol AssetAddressFetching {

    /// Checks usability of an asset address 
    func checkUsability(of address: String, asset: CryptoCurrency) -> Single<AddressUsageStatus>

    /// Return the candidate addresses by type and asset
    func addresses(by type: AssetAddressType, asset: CryptoCurrency) -> [AssetAddress]

    /// Removes a given asset address according to type
    func remove(address: String, for assetType: CryptoCurrency, addressType: AssetAddressType)
}
