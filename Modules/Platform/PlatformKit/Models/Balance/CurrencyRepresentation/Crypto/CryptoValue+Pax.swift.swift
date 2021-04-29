// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// MARK: - PAX

extension CryptoValue {
    
    public static var paxZero: CryptoValue {
        zero(currency: .pax)
    }
    
    public static func pax(major value: String) -> CryptoValue? {
        create(major: value, currency: .pax)
    }
    
    public static func pax(majorDisplay value: String) -> CryptoValue? {
        create(majorDisplay: value, currency: .pax)
    }
}
