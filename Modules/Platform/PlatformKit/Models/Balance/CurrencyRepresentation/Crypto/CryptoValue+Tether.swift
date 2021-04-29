// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// MARK: - Tether

extension CryptoValue {
    
    public static var tetherZero: CryptoValue {
        zero(currency: .tether)
    }

    public static func tether(majorDisplay value: String) -> CryptoValue? {
        create(majorDisplay: value, currency: .tether)
    }
}
