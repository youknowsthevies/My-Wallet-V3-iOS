//
//  LegacyCryptoCurrency.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

@available(*, deprecated, message: "This object is deprecated and will be deleted soon. Use `CryptoCurrency` instead.")
@objc
final class LegacyCryptoCurrency: NSObject {
    
    @objc
    static let bitcoin = LegacyCryptoCurrency(CryptoCurrency.bitcoin)
    
    @objc
    static let bitcoinCash = LegacyCryptoCurrency(CryptoCurrency.bitcoinCash)
    
    @objc
    static let ethereum = LegacyCryptoCurrency(CryptoCurrency.ethereum)
    
    @objc
    static let pax = LegacyCryptoCurrency(CryptoCurrency.pax)

    @objc
    static let stellar = LegacyCryptoCurrency(CryptoCurrency.stellar)

    @objc
    static let tether = LegacyCryptoCurrency(CryptoCurrency.tether)
        
    @objc
    var legacy: LegacyAssetType { value.legacy }
    
    @objc
    var name: String { value.name }
    
    @objc
    var displayCode: String { value.displayCode }
    
    @objc
    var code: String { value.code }

    let value: CryptoCurrency
    
    init(_ value: LegacyAssetType) {
        self.value = CryptoCurrency(legacyAssetType: value)
    }
    
    init(_ value: CryptoCurrency) {
        self.value = value
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LegacyCryptoCurrency else {
            return false
        }
        return value == object.value
    }
        
    @available(*, unavailable)
    override var description: String { value.name }
}

