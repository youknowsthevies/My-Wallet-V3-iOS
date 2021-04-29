// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

class MultiAddressResponse: NSObject {
    @objc var symbol_local: CurrencySymbol?

    @objc init(jsonString: String?) {
        super.init()
    }
}
