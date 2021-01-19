//
//  SingleAccountType.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public enum SingleAccountType: Hashable {
    case custodial(CustodialAccountType)
    case nonCustodial

    public enum CustodialAccountType: String, Hashable {
        case trading
        case savings

        var isTrading: Bool {
            self == .trading
        }

        var isSavings: Bool {
            self == .savings
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
