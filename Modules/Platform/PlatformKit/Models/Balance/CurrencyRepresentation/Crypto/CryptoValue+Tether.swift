//
//  CryptoValue+Tether.swift
//  PlatformKit
//
//  Created by Paulo on 09/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

// MARK: - Tether

extension CryptoValue {
    
    public static var tetherZero: CryptoValue {
        zero(currency: .tether)
    }

    public static func tether(majorDisplay value: String) -> CryptoValue? {
        create(majorDisplay: value, currency: .tether)
    }
}
