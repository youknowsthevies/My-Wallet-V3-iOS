// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum OrderDirection: String, Codable {
    /// From non-custodial to non-custodial
    case onChain = "ON_CHAIN"
    /// From non-custodial to custodial
    case fromUserKey = "FROM_USERKEY"
    /// From custodial to non-custodial
    case toUserKey = "TO_USERKEY"
    /// From custodial to custodial
    case `internal` = "INTERNAL"
}

extension OrderDirection {

    public var isFromCustodial: Bool {
        self == .toUserKey || self == .internal
    }

    public var isToCustodial: Bool {
        self == .fromUserKey || self == .internal
    }
}
