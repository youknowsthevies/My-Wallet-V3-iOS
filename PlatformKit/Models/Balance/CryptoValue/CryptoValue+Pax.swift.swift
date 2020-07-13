//
//  CryptoValue+Pax.swift.swift
//  PlatformKit
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

// MARK: - PAX

extension CryptoValue {
    public static var paxZero: CryptoValue {
        zero(assetType: .pax)
    }
    
    public static func paxFromMajor(string pax: String) -> CryptoValue? {
        createFromMajorValue(string: pax, assetType: .pax)
    }
}
