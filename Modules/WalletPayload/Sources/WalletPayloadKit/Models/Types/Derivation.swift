// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum DerivationType: String, Equatable {
    case legacy
    case segwit = "bech32"

    var purpose: Int {
        switch self {
        case .legacy:
            return 44
        case .segwit:
            return 84
        }
    }
}

public class Derivation: Equatable {
    var type: DerivationType
    var purpose: Int
    var xpriv: String
    var xpub: String
    var addressLabels: [AddressLabel]
    var cache: AddressCache

    public init(
        type: DerivationType,
        purpose: Int,
        xpriv: String,
        xpub: String,
        addressLabels: [AddressLabel],
        cache: AddressCache
    ) {
        self.type = type
        self.purpose = purpose
        self.xpriv = xpriv
        self.xpub = xpub
        self.addressLabels = addressLabels
        self.cache = cache
    }
}

extension Derivation {
    public static func == (lhs: Derivation, rhs: Derivation) -> Bool {
        lhs.type == rhs.type
            && lhs.purpose == rhs.purpose
            && lhs.xpriv == rhs.xpriv
            && lhs.xpub == rhs.xpub
            && lhs.addressLabels == rhs.addressLabels
            && lhs.cache == rhs.cache
    }
}
