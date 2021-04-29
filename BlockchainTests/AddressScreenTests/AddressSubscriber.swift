// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@testable import Blockchain
import PlatformKit

struct AddressSubscriberMock: AssetAddressSubscribing {
    func subscribe(to address: String, asset: CryptoCurrency, addressType: AssetAddressType) {}
}
