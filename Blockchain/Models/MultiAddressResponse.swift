//
//  MultiAddressResponse.swift
//  Blockchain
//
//  Created by Paulo on 14/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class MultiAddressResponse: NSObject {
    @objc var symbol_local: CurrencySymbol?

    @objc init(jsonString: String?) {
        super.init()
    }
}
