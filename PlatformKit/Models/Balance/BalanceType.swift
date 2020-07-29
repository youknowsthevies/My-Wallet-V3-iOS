//
//  BalanceType.swift
//  PlatformKit
//
//  Created by AlexM on 1/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum BalanceType: Hashable, CaseIterable {
    public static var allCases: [BalanceType] {
        [.nonCustodial] + CustodialType.allCases.map { .custodial($0) }
    }
    
    public enum CustodialType: String, Hashable, CaseIterable {
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
    
    public var isCustodial: Bool {
        switch self {
        case .custodial:
            return true
        case .nonCustodial:
            return false
        }
    }

    public var isTrading: Bool {
        switch self {
        case .custodial(let type):
            return type == .trading
        case .nonCustodial:
            return false
        }
    }

    public var isSavings: Bool {
        switch self {
        case .custodial(let type):
            return type == .savings
        case .nonCustodial:
            return false
        }
    }
}
