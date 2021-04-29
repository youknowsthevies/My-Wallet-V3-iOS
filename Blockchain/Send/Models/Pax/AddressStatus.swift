// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import Foundation

enum AddressStatus {
    case valid(EthereumAccountAddress)
    case invalid
    case empty
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        default:
            return false
        }
    }
    
    var address: EthereumAccountAddress? {
        switch self {
        case .valid(let address):
            return address
        default:
            return nil
        }
    }
}
