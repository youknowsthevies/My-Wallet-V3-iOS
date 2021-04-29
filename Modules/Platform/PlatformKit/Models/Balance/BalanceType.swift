// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@available(*, deprecated, message: "This should be replaced with SingleAccountBalanceType.")
public enum BalanceType: Hashable {
    
    public enum CustodialType: String, Hashable {
        case trading
        case savings
    }
    
    case nonCustodial
    case custodial(CustodialType)
    
    public var description: String {
        switch self {
        case .custodial(let type):
            return "custodial" + type.rawValue
        case .nonCustodial:
            return "nonCustodial"
        }
    }
}
