// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum KYCStatus: Int, Comparable {
    case noKyc = 0
    case silver = 1
    case gold = 2
    case platinum = 3

    public static func < (lhs: KYCStatus, rhs: KYCStatus) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
