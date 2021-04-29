// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum SingleAccountType: Hashable {
    case custodial(CustodialAccountType)
    case nonCustodial

    public enum CustodialAccountType: String, Hashable {
        case exchange
        case trading
        case savings

        var isTrading: Bool {
            self == .trading
        }

        var isSavings: Bool {
            self == .savings
        }
        
        var isExchange: Bool {
            self == .exchange
        }
    }

    public var isTrading: Bool {
        switch self {
        case .nonCustodial:
            return false
        case .custodial(let type):
            return type.isTrading
        }
    }
    
    public var isExchange: Bool {
        switch self {
        case .nonCustodial:
            return false
        case .custodial(let type):
            return type.isExchange
        }
    }

    public var isSavings: Bool {
        switch self {
        case .nonCustodial:
            return false
        case .custodial(let type):
            return type.isSavings
        }
    }

    public var description: String {
        switch self {
        case .custodial(let type):
            return "custodial.\(type.rawValue)"
        case .nonCustodial:
            return "noncustodial"
        }
    }
}
